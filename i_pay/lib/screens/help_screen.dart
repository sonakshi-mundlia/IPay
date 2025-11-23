import 'package:flutter/material.dart';
import '../services/stt_service.dart';
import '../services/tts_service.dart';
import '../services/api_service.dart';

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

  @override
  void initState() {
    super.initState();
    STTService.initialize();
  }

  Future startListening() async {
    setState(() => isListening = true);

    await STTService.startListening((text) async {
      recognizedText = text;

      if (text.isNotEmpty) {
        await STTService.stopListening();

        final reply = await ApiService().processVoiceCommand(text);

        setState(() {
          responseText = reply;
          isListening = false;
        });

        await TTSService.speak(reply);
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

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blueGrey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blueGrey.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text("You said:", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(recognizedText.isEmpty ? "..." : recognizedText),

                  const SizedBox(height: 8),

                  Text("Assistant:", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(responseText.isEmpty ? "..." : responseText),

                  const SizedBox(height: 12),

                  Center(
                    child: FloatingActionButton(
                      onPressed: startListening,
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
