import 'package:flutter/material.dart';

class PinSetupScreen extends StatefulWidget {
  const PinSetupScreen({super.key});

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  final pinController = TextEditingController();
  final confirmPinController = TextEditingController();

  bool loading = false;
  String msg = "";

  Future<void> setupPin() async {
    final pin = pinController.text.trim();
    final confirmPin = confirmPinController.text.trim();

    if (pin.length != 4) {
      setState(() => msg = "PIN must be 4 digits");
      return;
    }
    if (pin != confirmPin) {
      setState(() => msg = "PINs do not match");
      return;
    }

    setState(() => loading = true);

    /// TODO: API CALL HERE
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      loading = false;
      msg = "PIN created successfully!";
    });

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Set Transaction PIN")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: pinController,
              obscureText: true,
              maxLength: 4,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Enter 4-digit PIN"),
            ),
            TextField(
              controller: confirmPinController,
              obscureText: true,
              maxLength: 4,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Confirm PIN"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: loading ? null : setupPin,
              child:
              loading ? const CircularProgressIndicator() : const Text("Save PIN"),
            ),

            if (msg.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(msg,
                    style: const TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
              )
          ],
        ),
      ),
    );
  }
}
