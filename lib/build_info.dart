/// Version name from `pubspec.yaml`, passed at build time by
/// `scripts/build-apk.sh` as `--dart-define=APP_VERSION=...`.
const String appVersion = String.fromEnvironment(
  'APP_VERSION',
  defaultValue: 'dev',
);

/// First eight characters of the commit the build came from, passed by
/// `scripts/build-apk.sh` as `--dart-define=GIT_COMMIT=...`.
const String appCommit = String.fromEnvironment(
  'GIT_COMMIT',
  defaultValue: 'local',
);

/// The public repository, linked from the drawer so a user can read what the
/// app does with their API key.
const String sourceRepoUrl = 'https://github.com/Pitrified/fala-language-tutor';

/// How to install SherpaTTS and a voice, linked from the Speech section when
/// Sherpa is chosen but missing.
const String sherpaGuideUrl = '$sourceRepoUrl/blob/main/docs/sherpa-tts.md';

/// How to get an OpenAI API key, linked from the Model page.
const String openAiKeyGuideUrl = '$sourceRepoUrl/blob/main/docs/openai-key.md';

/// What the app shows as its version, for example `0.0.1+a739b0e1`. A build
/// without the defines, such as a plain `flutter run`, shows `dev+local`.
const String appVersionLabel = '$appVersion+$appCommit';
