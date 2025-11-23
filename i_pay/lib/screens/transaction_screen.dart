import 'package:flutter/material.dart';
import '../services/api_service.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  final apiService = ApiService();

  final TextEditingController receiverController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController pinController = TextEditingController();

  bool loading = false;
  String message = "";
  String selectedCategory = "transfer";


  void sendTransaction() async {
    final senderId = apiService.currentUserId;
    if (senderId == null) {
      setState(() {
        message = "Error: User not logged in.";
      });
      return;
    }

    final toIdText = receiverController.text.trim();
    final amount = double.tryParse(amountController.text.trim()) ?? 0;
    final pin = pinController.text.trim();

    if (toIdText.isEmpty || amount <= 0 || pin.isEmpty) {
      setState(() => message = "Please fill all fields correctly.");
      return;
    }

    int? toId;
    try {
      toId = int.parse(toIdText);
    } catch (e) {
      setState(() => message = "Receiver ID must be a number.");
      return;
    }

    setState(() {
      loading = true;
      message = "";
    });

    try {
      final response = await apiService.sendTransaction(
        senderId,
        toId,
        amount,
        pin,
      );

      setState(() {
        loading = false;
        if (response['success'] == true) {
          message = "Transaction successful ";
          receiverController.clear();
          amountController.clear();
          pinController.clear();
        } else {
          message = response['message'] ?? "Transaction failed ";
        }
      });
    } catch (e) {
      setState(() {
        loading = false;
        message = "Error: ${e.toString()}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Send Money")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: receiverController,
              decoration: const InputDecoration(labelText: "Receiver ID (numeric)"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(labelText: "Amount"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: const InputDecoration(
                labelText: "Category",
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: "transfer", child: Text("Transfer")),
                DropdownMenuItem(value: "payment", child: Text("Payment")),
                DropdownMenuItem(value: "bill", child: Text("Bill")),
                DropdownMenuItem(value: "recharge", child: Text("Recharge")),
                DropdownMenuItem(value: "donation", child: Text("Donation")),
                DropdownMenuItem(value: "salary", child: Text("Salary")),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedCategory = value;
                  });
                }
              },
            ),
            TextField(
              controller: pinController,
              decoration: const InputDecoration(labelText: "Transaction PIN"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: loading ? null : sendTransaction,
              child: loading
                  ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
                  : const Text("Send"),
            ),
            if (message.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(
                message,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
