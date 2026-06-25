import 'dart:async';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/foundation.dart';

class TTSService {
  static final FlutterTts _tts = FlutterTts();
  static bool _initialized = false;

  /// Initialize TTS
  static Future<void> init() async {
    if (_initialized) return;

    debugPrint("✅ Initializing TTS");

    // 🔴 CRITICAL LINE (DO NOT REMOVE)
    await _tts.awaitSpeakCompletion(true);

    await _tts.setLanguage("en-US");
    await _tts.setSpeechRate(0.45);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);

    _initialized = true;
  }

  /// Speak text and wait until finished
  static Future<void> speak(
      String text, {
        String language = "en-US",
      }) async {
    if (text.trim().isEmpty) return;

    if (!_initialized) await init();

    await _tts.setLanguage(language);

    debugPrint("🗣️ TTS SPEAKING: $text");

    // 🔥 THIS WILL BLOCK UNTIL AUDIO FINISHES
    await _tts.speak(text);

    debugPrint("🗣️ TTS FINISHED");
  }

  /// Stop TTS
  static Future<void> stop() async {
    await _tts.stop();
  }
}
