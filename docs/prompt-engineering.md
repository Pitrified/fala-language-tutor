# Prompt engineering guide

How prompts work in fala, which files are involved, and how to iterate on them.

---

## Architecture overview

```
assets/prompts/{name}/vN.txt        <-- prompt templates (versioned plain text)
assets/prompts/{name}_schema.json   <-- expected JSON schema (reference only)
lib/services/prompt/prompt_manager.dart  <-- loads + substitutes variables
lib/services/inference/structured_output_parser.dart  <-- parses LLM output
lib/services/inference/json_extractor.dart  <-- extracts JSON from raw text
lib/models/tutor_response.dart      <-- Dart model for structured output
```

---

## File roles

### `assets/prompts/tutor_response/v1.txt`

The prompt template sent to the model. Contains:

- System instruction (role, language, CEFR level)
- Exact JSON format the model must produce
- Rules constraining behavior
- Variable placeholders: `{{cefr_level}}`, `{{user_message}}`, `{{conversation_history}}`

This is the primary file you edit when improving response quality.

### `assets/prompts/tutor_response_schema.json`

JSON Schema describing the expected output structure. Used as documentation reference only (not enforced at runtime). Keep it in sync with `TutorResponse` model.

### `lib/services/prompt/prompt_manager.dart`

Loads the highest-versioned template from assets and substitutes `{{variable}}` placeholders with runtime values. Does NOT modify the prompt content itself.

### `lib/services/inference/json_extractor.dart`

Extracts JSON from whatever the model returns, using three strategies in order:

1. Direct parse (output is already pure JSON)
2. Markdown code block (` ```json ... ``` `)
3. JSON substring (first `{` to last `}`)

This means the model can output extra text around the JSON and it will still parse.

### `lib/services/inference/structured_output_parser.dart`

Wires `JsonExtractor` to the `TutorResponse.fromJson` factory. If extraction or deserialization fails, returns a `ParseFailure` with the raw text (which the UI shows as a fallback message).

### `lib/models/tutor_response.dart`

Freezed model defining the Dart types: `TutorResponse`, `CorrectionBlock`, `ConversationBlock`, `CorrectionError`. Generated code handles JSON deserialization. The field names here must match the JSON keys in the prompt template.

---

## How to iterate on a prompt

### 1. Never edit an existing version

Create a new version file instead:

```
assets/prompts/tutor_response/v2.txt
```

The `PromptManager` auto-selects the highest version number (scans v10 down to v1).

### 2. Template variables available

| Variable | Source | Description |
|----------|--------|-------------|
| `{{cefr_level}}` | Conversation metadata | A1, A2, B1, B2, C1, C2 |
| `{{user_message}}` | User input | The message the user just typed |
| `{{conversation_history}}` | Last N messages | Formatted history for context |

### 3. Output constraints

The OpenAI engine sends `tutor_response_schema.dart` as a strict `json_schema` response format, so
the reply is well-formed JSON with every required field. The prompt still shows the structure and
says to output only the JSON, because the schema constrains shape, not content: which fields carry
the correction and which the reply is the prompt's job.

### 4. Testing prompts without building APK

Use the fake engine with a modified response to test parsing:

```bash
flutter test test/services/prompt_manager_test.dart
```

Or run the full app with `--dart-define=FAKE_ENGINE=true` to bypass the API entirely and test UI flow with canned responses.

### 5. Comparing prompts and models

`scripts/prompt_lab/lab.py` plays a scripted conversation through each prompt and model in an experiment file and tabulates reply length, CEFR level as rated by a judge model, correction quality and streaming timings. Its [README](../scripts/prompt_lab/README.md) describes the experiment format. It talks to any OpenAI-compatible endpoint, so other providers can be compared the same way.

### 6. Debugging model output

When the model produces unexpected output:

1. Check logcat for the raw response:
   ```bash
   adb logcat --pid=$(adb shell pidof com.fala.app) | grep "flutter"
   ```

2. If the JSON is malformed, the `JsonExtractor` will fail and `StructuredParseFailure` fires. The UI shows the raw text as a fallback.

3. Common issues:
   - Model outputs text before/after JSON -> `JsonExtractor` handles this (strategy 3)
   - Model hallucinates extra fields -> `fromJson` ignores unknown keys (freezed default)
   - Model omits required fields -> Parse fails, raw text shown

---

## Adding a new prompt type

1. Create folder: `assets/prompts/{new_name}/v1.txt`
2. Add schema reference: `assets/prompts/{new_name}_schema.json`
3. Create Dart model in `lib/models/{new_name}.dart` with `@freezed` + `fromJson`
4. Register in `pubspec.yaml` assets (glob `assets/prompts/` already covers it)
5. Create a new `StructuredInferenceEngine<NewModel>` provider wired with the appropriate parser

---

## Current prompt: tutor_response v3

The template names no language of its own. It takes `{{target_language}}` (the language being
learned, e.g. `Portuguese (Brazilian)`) and `{{explanation_language}}` (the language corrections and
translations are written in, English today), alongside `{{cefr_level}}`, `{{topic}}`,
`{{user_message}}` and `{{conversation_history}}`. `PromptManager.buildPrompt` throws if any of them
is left unsubstituted, because a literal `{{target_language}}` reaching the model produces a reply in
a guessed language rather than an error.

The prompt instructs the model to:

- Act as a tutor in the target language
- Correct errors in the user's message (max 3)
- Reply conversationally in the target language
- Include translations in the explanation language
- Output structured JSON matching `TutorResponse` schema
- Match complexity to the user's CEFR level

Worked example, with Portuguese as the target: the model is told it is a
"Portuguese (Brazilian) language tutor", replies in Portuguese and translates into English.

The prompt is tuned against the OpenAI model set in Settings, `gpt-4o-mini` by default.
