# fala-language-tutor

**fala** is an Android language-tutoring app. The learner types in the language they are
learning and gets back a structured correction, a translation and a conversational reply,
streamed token by token.

It was built inside [flutter-setup-project](https://github.com/Pitrified/flutter-setup-project),
which is now a guide to setting up Flutter and a gallery of patterns. This repo has the tutor on
its own; that repo keeps the development history from before the split.

## What it does today

- **The OpenAI chat completions API** through `openai_dart`, with the user's key in
  `flutter_secure_storage` and the reply constrained to a JSON schema. A fake engine with
  scripted replies stands in for it in tests and for trying the UI without a key.
- **The target language is a setting.** Portuguese (Brazilian) by default, with Spanish,
  French, Italian and German offered; explanations stay in English.
- **CEFR level, topic and translation-on-tap**, with the tutor's structured reply rendered
  as it arrives rather than after it completes.
- Android only, min API 26, target API 36. Flutter 3.44.5.

## Where to look

| Location | What is in it |
|----------|---------------|
| [docs/](docs/) | What the project is now: specs, standards, build and release, prompt design |
| [docs/getting-started.md](docs/getting-started.md) | Run the gates, run the app, run the emulator end-to-end check |
| [docs/functional-specs.md](docs/functional-specs.md) | Scope, locked decisions, screens, error handling |
| [docs/library/](docs/library/) | Per-system reference: the engines, controllers, parser, repository |
| [.github/copilot-instructions.md](.github/copilot-instructions.md) | The rules an AI assistant works under here |
| [plans/](plans/) | The development diary: how the project got to where it is |

**Docs are the as-is; plans are the diary.** A decision worth citing lives in the docs file
whose topic it is. The plan folders record how each feature was reasoned about, in the shape the
`tracked-development` skill describes, and they are not maintained as documentation.

To read the diary as a list rather than by opening folders:

```bash
python3 scripts/plans.py list                 # every feature, by priority
python3 scripts/plans.py list --status "in progress"
python3 scripts/plans.py list --index 02      # what that folder contains
```

## Gates

```bash
scripts/check.sh          # links, plan folders, codegen, format, analyze, test (-v for full output)
scripts/install-hooks.sh  # once per clone, so a commit runs them too
scripts/e2e.sh            # the slow one: headless emulator plus a mocked OpenAI endpoint
```

CI runs `scripts/check.sh` and nothing else. Generated files (`*.freezed.dart`, `*.g.dart`)
are gitignored, so a fresh clone needs the codegen gate before anything else will compile.
