# Functional Specification

> **Status:** Source of truth. Nothing gets implemented unless it appears here.

## 1. Overview

- **App name:** fala (Portuguese for "speak")
- **Package ID:** `com.fala.app`
- **Purpose:** language tutoring via conversational AI
- **Core value:** structured corrections + natural conversation, from a cloud LLM with the user's own key
- **Target language:** a setting (`default_language`), one of Portuguese (Brazilian),
  Spanish, French, Italian or German. Portuguese is the default; English is not offered
  while corrections and translations are written in English
- **Primary interaction:** text chat with a tutor that corrects grammar/vocabulary and continues the conversation

## 2. Core Technical Decisions (locked)

| Concern | Decision |
|---------|----------|
| Framework | Flutter (Dart) |
| Platform | Android only |
| State management | Riverpod |
| Navigation | GoRouter |
| Local storage | Hive |
| LLM inference | OpenAI chat completions via `openai_dart` (swappable via the InferenceEngine interface) |
| Models (codegen) | freezed + json_serializable |
| Output enforcement | OpenAI strict `json_schema` response format, then parsing into `TutorResponse` |
| Model | An OpenAI model picked in Settings from the ones the prompt was compared on, `gpt-5.4-nano` by default; see [prompt-engineering.md](prompt-engineering.md) |
| API key | The user's own, stored in `flutter_secure_storage` |
| Min Android version | API 26 (Android 8.0) |
| Target Android version | API 36 (Android 16) |
| Difficulty system | A1-C2 CEFR levels via prompt templates |
| Target language | A setting, `TargetLanguage`, defaulting to `pt-BR` |

### Target language

The language being learned is a setting, not a constant. `TargetLanguage`
(`lib/models/target_language.dart`) is the closed set the app offers, and every
language-dependent string, prompt variable and piece of UI copy reads from it.

- **Default `pt-BR`.** Brazilian Portuguese is what the app was built around and
  what its store copy says; the default is the app's, not the device locale's.
- **Explanations stay in English.** Corrections and translations are written in
  English whatever the target language is, so the learner reads the explanation in
  a language they already have.
- **`en-US` is deliberately absent.** An English tutor explaining English in
  English has nothing to translate, so the enum does not offer it, and a test
  asserts that it does not.
- **A conversation's language is fixed once it has messages.** Changing the
  setting changes the default for the next conversation; changing it from inside a
  conversation that already has history offers a restart or keeping the current
  one, and `setLanguage` raises `LanguageLockedException` rather than rewriting
  history in a language it was not spoken in.

## 3. Platform Constraints

- Internet access for every tutor turn; nothing runs on the device beyond the app itself
- No hardware floor beyond Android 8.0 (API 26); inference is remote
- 64-bit ABIs only (arm64-v8a, x86_64); see `docs/build-and-release.md`

## 4. Application Lifecycle

```
App Launch
  -> Initialize Hive, load settings and conversations
  -> Welcome Screen: initialize the selected InferenceEngine
  -> If it fails: show the error with a retry
  -> User starts conversation
  -> Conversation Screen (main loop)
```

## 5. Screen Inventory

| Screen | Purpose | Lifetime |
|--------|---------|----------|
| Welcome | App entry, runtime status, start session (or model setup when a key is missing; on a new install, "Get started" into the first-run setup) | Until navigation |
| First-run setup | Three pages in order: the Model page's settings (Next once the model is ready, or "Set it later"), language and level, then reply length, "say it better" and speech. The last two start from the defaults. Shown on a new install, one with no key stored, until Start on the last page; Start opens the conversation, or the welcome screen while the model still needs setup | Until navigation |
| Settings | Index of the settings pages, also listed in the conversation drawer | Until navigation |
| Language | Target language and CEFR level, applied to the open conversation and to new ones; the reply length (short, normal, long); "say it better" with every reply or on request; the "Read replies aloud" switch, and the speech engine and a local voice per language | Until navigation |
| Model | Engine, then the selected engine's details (OpenAI key and model) | Until navigation |
| Diagnostics | The diagnostics log under a header on the app, phone and current choices, with Copy and Clear, for pasting back after a run on the phone | Until navigation |
| Conversation | Main interaction: messages, input, corrections, "say it better" under a reply, or the sparkle beside a reply that asks for it; the app bar holds the topic picker, the drawer the settings, a link to the source repository and the version | Session-scoped |

## 6. Systems

| System | Spec location |
|--------|---------------|
| AppController | [library/app-controller.md](library/app-controller.md) |
| InferenceEngine | [library/inference-engine.md](library/inference-engine.md) |
| ConversationController | [library/conversation-controller.md](library/conversation-controller.md) |
| StructuredOutputSystem | [library/structured-output-system.md](library/structured-output-system.md) |
| ConversationRepository | [library/conversation-repository.md](library/conversation-repository.md) |
| PromptManager | [library/prompt-manager.md](library/prompt-manager.md) |

## 7. Interaction Model

1. User types a message in the conversation's target language
2. App builds prompt: system instructions + schema + history subset + user message
3. InferenceEngine produces structured JSON output
4. Output parsed into: correction block + conversation block
5. Correction shown if errors found; conversation reply always shown
6. Message pair persisted to history

## 8. Structured Output Schema

```json
{
  "correction": {
    "content": "corrected sentence in target language",
    "translation": "English translation",
    "errors": [
      {
        "original": "what user wrote",
        "corrected": "fixed version",
        "explanation": "brief grammar/vocab note"
      }
    ]
  },
  "conversation": {
    "content": "tutor reply in target language",
    "translation": "English translation"
  },
  "better": {
    "content": "the user's message rewritten a step richer",
    "translation": "English translation"
  }
}
```

If the user's message has no errors, `correction.content`, `correction.translation`,
and `correction.errors` are empty/empty list. `better` is empty unless "say it better" was asked for, and in replies saved before it existed.

## 9. Persistence

| Hive box | Dart model | Contents |
|----------|------------|----------|
| conversations | `Conversation` (list of `ConversationMessage` with `TutorResponse`) | Messages: role, content, timestamp, correction data |
| app_settings | `AppSettingsRepository` (plain strings) | Engine kind, OpenAI model id, target language, CEFR level, reply length, "say it better" with every reply, first-run setup done, recent topics, read replies aloud, speech engine, voice per language |
| diagnostics | `DiagnosticsLog` (plain strings) | Newest 500 lines: one per reply read aloud (trigger, language, engine, voice, length, timings, outcome) and per speech choice; no message text |

## 10. Error Handling

| Failure | Fallback |
|---------|----------|
| No API key stored for an engine that needs one | Welcome offers "Setup model" instead of "Start learning"; the conversation shows a red "Model setup needed" strip under the app bar. Both open the Model page |
| Rejected API key | Failure message pointing at Settings |
| Network error or rate limit | Failure message, allow retry |
| Engine initialization fails | Error on the Welcome screen with a retry |
| Inference timeout | Show timeout message, allow retry |
| Invalid structured output | Show raw text reply, log error for debugging |
| Storage corrupt | Reset conversation, preserve settings |

## 11. Logging and Debugging

- `AppLogger` (never `print`/`debugPrint` directly)
- Log levels: info, warn, error
- Debug overlay: model info, inference time, token count, prompt version
- Logs stored in app storage, exportable for bug reports

## 12. Definition of Demo-Ready

- [ ] App launches on Android emulator in < 5 seconds (cold start)
- [ ] User can send a message and receive a structured correction + reply
- [ ] Conversation persists across app restarts
- [ ] Invalid model output shows graceful fallback (not a crash)
- [ ] Loading states visible during inference

## 13. Milestones

| Milestone | Definition |
|-----------|------------|
| M0 | Repo created, docs complete, environment working |
| M1 | Empty app builds and runs on emulator |
| M2 | Fake engine conversation loop works end-to-end |
| M3 | Real inference produces structured output |
| M4 | Full flow: infer, correct, persist, reload |
| M5 | Private alpha on Google Play |

## 14. Out of Scope

Explicitly forbidden (not "later" - not allowed to leak into the codebase):

- On-device inference (it was built and removed; it lives on as a pattern in flutter-setup-project)
- Multiple languages simultaneously (one at a time)
- Speech-to-text or text-to-speech
- User accounts or cloud sync
- Social features (leaderboards, sharing)
- Gamification (points, streaks, achievements)
- iOS, web, or desktop support
- Ads, analytics, telemetry
- In-app purchases
- Multiple conversation types (only tutor conversation)
- Custom model training/fine-tuning in-app
- Model marketplace or model switching UI
