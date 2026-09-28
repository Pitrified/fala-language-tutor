package com.fala.app

import android.content.ActivityNotFoundException
import android.content.Intent
import android.os.Build
import android.speech.tts.TextToSpeech
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // What flutter_tts does not cover: sending the user to install a voice,
        // and the phone's make and Android version for the diagnostics page.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "fala/speech")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "openVoiceInstall" -> result.success(openVoiceInstall())
                    "deviceInfo" -> result.success(
                        mapOf(
                            "maker" to Build.MANUFACTURER,
                            "model" to Build.MODEL,
                            "release" to Build.VERSION.RELEASE,
                            "sdk" to Build.VERSION.SDK_INT.toString(),
                        ),
                    )
                    else -> result.notImplemented()
                }
            }
    }

    /**
     * The engine's install-voice-data screen, or the text-to-speech settings
     * when the engine has none. False when neither exists.
     */
    private fun openVoiceInstall(): Boolean {
        val actions = listOf(
            TextToSpeech.Engine.ACTION_INSTALL_TTS_DATA,
            "com.android.settings.TTS_SETTINGS",
        )
        for (action in actions) {
            try {
                startActivity(Intent(action))
                return true
            } catch (e: ActivityNotFoundException) {
                continue
            }
        }
        return false
    }
}
