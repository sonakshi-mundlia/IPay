import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../app_state.dart';

class PinResetScreen extends StatefulWidget {
  const PinResetScreen({super.key});

  @override
  State<PinResetScreen> createState() => _PinResetScreenState();
}

class _PinResetScreenState extends State<PinResetScreen> {
  final oldPinController = TextEditingController();
  final newPinController = TextEditingController();
  final confirmPinController = TextEditingController();

  bool loading = false;
  String msg = "";

  int? _currentAccountId;

  @override
  void initState() {
    super.initState();
    _currentAccountId = AppState().currentAccountId;
    // Optional: listen to account changes
    AppState().currentAccountNotifier.addListener(_onAccountChanged);
  }

  void _onAccountChanged() {
    final newId = AppState().currentAccountId;
    if (_currentAccountId != newId) {
      setState(() {
        _currentAccountId = newId;
        // Clear PIN fields and message when account changes
        oldPinController.clear();
        newPinController.clear();
        confirmPinController.clear();
        msg = "";
      });
    }
  }

  @override
  void dispose() {
    oldPinController.dispose();
    newPinController.dispose();
    confirmPinController.dispose();
    AppState().currentAccountNotifier.removeListener(_onAccountChanged);
    super.dispose();
  }

  Future<void> resetPin() async {
    if (_currentAccountId == null) {
      setState(() => msg = "No account selected");
      return;
    }

    final oldPin = oldPinController.text.trim();
    final newPin = newPinController.text.trim();
    final confirmPin = confirmPinController.text.trim();

    if (oldPin.length != 4) {
      setState(() => msg = "Old PIN must be 4 digits");
      return;
    }
    if (newPin.length != 4) {
      setState(() => msg = "New PIN must be 4 digits");
      return;
    }
    if (newPin != confirmPin) {
      setState(() => msg = "New PINs do not match");
      return;
    }

    setState(() {
      loading = true;
      msg = "";
    });

    try {
      final url = Uri.parse("http://127.0.0.1:8000/pin/reset");

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "account_id": _currentAccountId, // ✅ Now reactive
          "old_pin": oldPin,
          "new_pin": newPin,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() => msg = data["message"] ?? "PIN updated");
        Navigator.pop(context, true);
      } else {
        setState(() => msg = data["detail"] ?? "Failed to reset PIN");
      }
    } catch (e) {
      setState(() => msg = "Server connection failed");
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reset Transaction PIN")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: oldPinController,
              obscureText: true,
              maxLength: 4,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Old PIN"),
            ),
            TextField(
              controller: newPinController,
              obscureText: true,
              maxLength: 4,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "New PIN"),
            ),
            TextField(
              controller: confirmPinController,
              obscureText: true,
              maxLength: 4,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Confirm New PIN"),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : resetPin,
                child: loading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Text("Reset PIN"),
              ),
            ),
            if (msg.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  msg,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
