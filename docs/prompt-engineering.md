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

## Current prompt: tutor_response v4

The template names no language of its own. It takes `{{target_language}}` (the language being
learned, e.g. `Portuguese (Brazilian)`) and `{{explanation_language}}` (the language corrections and
translations are written in, English today), alongside `{{cefr_level}}`, `{{topic}}`,
`{{user_message}}` and `{{conversation_history}}`. `PromptManager.buildPrompt` throws if any of them
is left unsubstituted, because a literal `{{target_language}}` reaching the model produces a reply in
a guessed language rather than an error.

It follows OpenAI's prompting guidance: the part above the `=== USER ===` line goes out as a `developer` message (identity, correction and reply instructions, examples), the part below as the `user` message, with the topic, the history and the learner's message in XML tags. `PromptManager.split` cuts it; `InferenceRequest.developerPrompt` carries the developer part. The JSON shape is left to the schema; the prompt says what each field means.

How complex and how long the reply is comes from `assets/prompts/tutor_response/reply_style.json`, read by `ReplyStyle`:

| Variable | From |
| -- | -- |
| `{{reply_level}}` | `reply_level`: the level the reply is written at. It is the learner's level except for C1, which gets C2, because the models write about one level below the one asked for at the top of the scale; the learner sees C1 text |
| `{{level_guide}}` | `level_guide` for the reply level: sentence length, tenses, vocabulary. Written without grammar names of one language, so it fits every target language |
| `{{reply_samples}}` | `samples` for the target language and reply level, one or two sample replies with a line asking to match their level and not their content. Empty for a language without samples (pt-BR and es-ES have them) |
| `{{length_rule}}` | `length_rule` for the Reply length setting on the Language page: `short`, `normal` or `long`. The API's own `verbosity` parameter was tried instead and barely changed the length |

The level guides alone and the samples alone each moved the reply level less than the two together.

The tutor plays a person in the chat and may tell small stories of its own to keep the conversation going.

A correction whose `corrected` equals its `original` is dropped from the finished reply, and a correction left with no errors that only repeats the learner's message is cleared (`correction_filter.dart`). gpt-5.4-nano writes such entries as "this part is fine" notes despite the prompt asking it not to. While the reply streams they can show for a moment.

## Models

The Model page offers the models the prompt was compared on with the prompt lab, listed in `lib/services/inference/openai_models.dart` with one line each on how they differ:

| Model | Why it is offered |
| -- | -- |
| `gpt-5.4-nano` (default) | Fastest to start the reply, and the most natural text at B2 to C2. Now and then misses a small error, and sometimes lists a correct phrase as an error with `corrected` equal to `original`. |
| `gpt-6-luna` | The most precise corrections, at about a fifth of the default's cost per turn. Slower to start the reply; at C1 it writes closer to B2. |

Both are reasoning models and are sent `reasoning_effort: none`: with any higher effort they spend hidden output tokens before answering, and reject a temperature other than 1. A higher effort made no visible difference to the replies. A model id stored before the list existed stays selected and is sent without `reasoning_effort`.
