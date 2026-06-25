import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart'; // For VoidCallback

typedef SpeechResultCallback = void Function(String text);

class STTService {
  static final SpeechToText _speech = SpeechToText();
  static bool _initialized = false;
  static bool isListening = false;

  static Timer? _silenceTimer;

  /// Callback to notify UI when mic stops
  static VoidCallback? onStopCallback;

  /// Request microphone permission
  static Future<bool> _requestMicPermission() async {
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      print('[STT] Microphone permission denied');
      return false;
    }
    return true;
  }

  /// Initialize STT
  static Future<void> init() async {
    if (!_initialized) {
      if (!await _requestMicPermission()) return;
      _initialized = await _speech.initialize(
        onStatus: (status) => print('[STT] Status: $status'),
        onError: (error) => print('[STT] Error: $error'),
      );
      print('[STT] Initialized: $_initialized');
    }
  }

  /// Start listening
  static Future<void> startListening(SpeechResultCallback onText) async {
    if (!_initialized) await init();
    if (!_initialized) return;
    if (isListening) return;

    isListening = true;
    _silenceTimer?.cancel();

    await _speech.listen(
      listenFor: const Duration(minutes: 5),
      pauseFor: const Duration(seconds: 10),
      partialResults: true,
      onResult: (result) async {
        final words = result.recognizedWords;

        if (words.isNotEmpty) print('[STT] Recognized: $words');

        // If final result, send text and stop
        if (result.finalResult && words.isNotEmpty) {
          onText(words);
          await stopListening();
          print('[STT] Stopped after final result');
        }

        // Auto-stop after 10s silence
        _silenceTimer?.cancel();
        _silenceTimer = Timer(const Duration(seconds: 10), () async {
          if (isListening) {
            await stopListening();
            print('[STT] Stopped after 10s silence');
          }
        });
      },
    );

    print('[STT] Listening started');
  }
  static Future<String> listenOnce() async {
    final completer = Completer<String>();

    await startListening((text) async {
      if (!completer.isCompleted && text.trim().isNotEmpty) {
        completer.complete(text.trim());
        await stopListening();
      }
    });

    return completer.future;
  }

  /// Stop listening
  static Future<void> stopListening() async {
    if (!isListening) return;

    _silenceTimer?.cancel();
    _silenceTimer = null;

    await _speech.stop();
    isListening = false;
    print('[STT] Listening stopped');

    // Notify UI once
    onStopCallback?.call();
  }

  /// Toggle listening (for UI button)
  static Future<void> toggleListening(SpeechResultCallback onText) async {
    if (isListening) {
      await stopListening();
    } else {
      await startListening(onText);
    }
  }
}
