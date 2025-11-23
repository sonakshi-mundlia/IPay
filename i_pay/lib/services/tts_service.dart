import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  static final FlutterTts _tts = FlutterTts();

  static Future speak(String text, {String? language}) async {
    if (language != null) {
      await _tts.setLanguage(language);
    }
    await _tts.setPitch(1.0);
    await _tts.setSpeechRate(0.45);
    await _tts.speak(text);
  }
}
