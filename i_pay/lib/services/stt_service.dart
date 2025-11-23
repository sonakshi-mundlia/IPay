import 'package:speech_to_text/speech_to_text.dart' as stt;

class STTService {
  static final stt.SpeechToText _speech = stt.SpeechToText();

  static Future<bool> initialize() async {
    return await _speech.initialize();
  }

  static Future startListening(Function(String) onResult) async {
    await _speech.listen(
      onResult: (result) => onResult(result.recognizedWords),
      localeId: "",
    );
  }

  static Future stopListening() async {
    await _speech.stop();
  }
}
