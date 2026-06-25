import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../app_state.dart'; // adjust path if needed

class CheckBalanceScreen extends StatefulWidget {
  const CheckBalanceScreen({super.key});

  @override
  State<CheckBalanceScreen> createState() => _CheckBalanceScreenState();
}

class _CheckBalanceScreenState extends State<CheckBalanceScreen> {
  final TextEditingController _pinController = TextEditingController();
  bool loading = false;
  Map<String, dynamic>? balanceData;

  Future<void> _checkBalance(int accountId) async {
    if (_pinController.text.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter valid 4 or 6 digit UPI PIN")),
      );
      return;
    }

    setState(() => loading = true);

    try {
      final response = await ApiService().checkBalance(
        accountId: accountId,
        transactionPin: _pinController.text,
      );

      setState(() {
        balanceData = response;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Widget _balanceContainer() {
    if (balanceData == null) return const SizedBox();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        color: Colors.blue.shade700,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            balanceData!["bank_name"] ?? "Bank",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Acct: ${balanceData!["account_number"]}",
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 12),
          const Text(
            "Available Balance",
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 5),
          Text(
            "₹${balanceData!["balance"]}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Check Balance")),
      body: ValueListenableBuilder<int?>(
        valueListenable: AppState().currentAccountNotifier,
        builder: (context, accountId, _) {
          if (accountId == null) {
            return const Center(
              child: Text("No account selected"),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Account header
                Row(
                  children: [
                    Icon(Icons.account_balance,
                        color: Colors.blue.shade700),
                    const SizedBox(width: 10),
                    Text(
                      "Account ID: $accountId",
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                TextField(
                  controller: _pinController,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: 6,
                  decoration: const InputDecoration(
                    labelText: "Enter UPI PIN",
                    border: OutlineInputBorder(),
                    counterText: "",
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: loading
                        ? null
                        : () => _checkBalance(accountId),
                    child: loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Check Balance"),
                  ),
                ),

                _balanceContainer(),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }
}
