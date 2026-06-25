import 'package:flutter/material.dart';
import '../services/stt_service.dart';
import '../services/tts_service.dart';
import '../services/api_service.dart';
import '../voice/voice_handler.dart';
import '../models/voice_model.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  String recognizedText = "";
  String responseText = "";
  bool isListening = false;

  final List<Map<String, String>> faqs = const [
    {
      "question": "How do I add a new account?",
      "answer": "Go to the Accounts section and tap the '+' button. Fill VPA, account number, and IFSC code."
    },
    {
      "question": "How do I check my balance?",
      "answer": "Ask the voice assistant 'What is my balance?' or check Home screen account details."
    },
    {
      "question": "How do I send money?",
      "answer": "Use the voice assistant: 'Send 500 rupees to Rohan' or use Transactions screen."
    },
    {
      "question": "What if a transaction fails?",
      "answer": "Verify account balance and receiver details. If still failing, contact support via Help Center."
    },
  ];

  /// Start or stop the mic
  Future<void> onMicTap() async {
    if (isListening) {
      await STTService.stopListening();
      if (!mounted) return;
      setState(() => isListening = false);
      return;
    }

    setState(() => isListening = true);

    await STTService.startListening((String text) async {
      print("STT callback fired with text: $text");
      if (!mounted) return;

      // Update recognized text safely on platform thread
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() => recognizedText = text);
      });

      if (text.isNotEmpty) {
        await STTService.stopListening();
        if (!mounted) return;
        setState(() => isListening = false);

        // Call backend to process voice command
        final VoiceResponse reply =
        await ApiService().processVoiceCommand(text);

        // Update assistant response safely
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          setState(() => responseText = reply.speech);
        });

        // Speak response
        await TTSService.speak(reply.speech);

        // Auto-navigation
        await VoiceHandler.handleRecognition(context: context, response: reply);
      } else {
        if (!mounted) return;
        setState(() => isListening = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Help Center")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // FAQs
            Expanded(
              child: ListView.builder(
                itemCount: faqs.length,
                itemBuilder: (context, index) {
                  final faq = faqs[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ExpansionTile(
                      title: Text(faq['question']!),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(faq['answer']!),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),

            // Voice panel
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blueGrey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blueGrey.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text("You said:", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(recognizedText.isEmpty ? "..." : recognizedText),
                  const SizedBox(height: 8),
                  const Text("Assistant:", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(responseText.isEmpty ? "..." : responseText),
                  const SizedBox(height: 12),
                  // Mic button
                  Center(
                    child: FloatingActionButton(
                      onPressed: onMicTap,
                      backgroundColor: isListening ? Colors.red : Colors.blue,
                      child: Icon(isListening ? Icons.mic : Icons.mic_none),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
