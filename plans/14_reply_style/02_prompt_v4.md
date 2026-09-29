---
status: done
---

# 02 - Level-shaped prompt in the app

## Overview

The prompt that came out of the prompt lab (lab name v7, `prompt_lab/v7.txt`) becomes the app's `tutor_response/v4.txt`, with the level guides, the samples and the no-op filter the user asked for after run 3 and 4 in `00_start.md`.

## Change

- `assets/prompts/tutor_response/v4.txt`: v7, with the level for the reply as its own variable `{{reply_level}}` next to the learner's `{{cefr_level}}`, and the samples block as one variable `{{reply_samples}}`, empty for a language without samples.
- `assets/prompts/tutor_response/reply_style.json`: the level a reply is written at for each learner level (C1 learners get C2 replies: "if to have c1 we need to send in a c2 prompt, then it's ok", user), the level guides, rewritten without Portuguese grammar names so they fit any target language, the samples for pt-BR and es-ES, and the length rules. The prompt lab reads the same file.
- `PromptManager`: loads `reply_style.json`; splits a built prompt at `=== USER ===` into a developer part and a user part.
- `InferenceRequest.developerPrompt`; `OpenAiInferenceEngine` sends it as a `developer` message before the user message.
- `ConversationController`: fills the new variables, the length rule fixed at `normal` until phase 03; drops errors whose `corrected` equals `original` from the finished reply, and clears the correction when nothing is left and it only repeats the message. While streaming they still show.
- `scripts/prompt_lab/lab.py`: a table can take its values from a key of a JSON file and look them up by several variables.
- Docs: `prompt-engineering.md` (current prompt), `library/` where the structured output system describes the request.

## Tests

- The developer prompt goes out as a `developer` message before the user message; without one, only the user message.
- The controller passes the reply level, guide, samples and length rule; C1 gets the C2 guide; es-ES gets Spanish samples, a language without samples an empty block.
- No-op errors are dropped from the saved reply; a correction left with no errors that repeats the message is cleared; a real error stays.
- `v4.txt` builds with the controller's variables and splits in two.

## Done when

- The tests pass and `scripts/check.sh` passes.
- A prompt lab run of `v4.txt` through `reply_style.json` looks like run 4.
- On the Pixel, replies at B1 and C1 read at their level, and no correction shows a phrase changed into itself.
