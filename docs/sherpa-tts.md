# Sherpa voices for fala

fala reads replies aloud with a text-to-speech engine on the phone. Google's engine works out of the box. SherpaTTS is a free, open-source engine whose voices run on the phone too, and some sound less robotic.

## Install

1. Install SherpaTTS from F-Droid: <https://f-droid.org/en/packages/org.woheller69.ttsengine/>. It is not on the Play Store. It needs Android 10 or later. The source is at <https://github.com/woheller69/ttsEngine>.
2. Open SherpaTTS, go to "Manage Languages" and download a voice for the language you are learning:
   - Brazilian Portuguese: `pt_BR-dii-high`.
   - Spanish (Spain): `es_ES-davefx-medium` or `es_ES-sharvard-medium`.
3. In fala: Settings > Language > Speech, set Engine to Sherpa. Leave Voice on "Engine default"; SherpaTTS uses the voice you downloaded.

A voice is downloaded once, then works offline. SherpaTTS keeps one voice per language.

## Notes

- `high` voices are larger and sound smoother; `medium` ones start a little faster. Settings > Diagnostics shows the time to the first sound of each reply.
- With Sherpa chosen and no Sherpa voice for a language, fala says the voice is missing, the same as for Google.
