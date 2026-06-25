import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../app_state.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  final ApiService apiService = ApiService();

  final TextEditingController searchController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController pinController = TextEditingController();

  bool loading = false;
  String message = "";

  /// Receiver ACCOUNT id (not user id)
  int? receiverAccountId;

  String selectedCategory = "transfer";
  List<Map<String, dynamic>> searchResults = [];

  @override
  void initState() {
    super.initState();
    // Listen for account changes
    AppState().currentAccountNotifier.addListener(_onAccountChanged);
  }

  @override
  void dispose() {
    AppState().currentAccountNotifier.removeListener(_onAccountChanged);
    super.dispose();
  }

  void _onAccountChanged() {
    // Clear UI when account changes
    setState(() {
      receiverAccountId = null;
      searchController.clear();
      amountController.clear();
      pinController.clear();
      message = "";
      searchResults.clear();
    });
  }

  // ---------------- SEARCH USERS ----------------
  Future<void> searchUsers(String query) async {
    if (query.length < 3) {
      setState(() => searchResults.clear());
      return;
    }

    final results = await apiService.searchUsers(query);
    setState(() => searchResults = results);
  }

  // ---------------- SEND TRANSACTION ----------------
  Future<void> sendTransaction() async {
    final int? fromSenderId = AppState().currentAccountId;

    if (fromSenderId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select an account")),
      );
      return;
    }

    if (receiverAccountId == null) {
      setState(() => message = "Please select a receiver account");
      return;
    }

    if (fromSenderId == receiverAccountId) {
      setState(() => message = "Cannot send to the same account");
      return;
    }

    final amount = double.tryParse(amountController.text.trim()) ?? 0;
    final pin = pinController.text.trim();

    if (amount <= 0 || pin.length != 4) {
      setState(() => message = "Enter valid amount and 4-digit PIN");
      return;
    }

    setState(() {
      loading = true;
      message = "";
    });

    try {
      final response = await apiService.sendTransaction(
        fromAccountId: fromSenderId,
        toAccountId: receiverAccountId!,
        amount: amount,
        pin: pin,
        category: selectedCategory,
      );

      setState(() {
        loading = false;
        message = response['success'] == true
            ? "✅ Transaction successful"
            : (response['message'] ?? "Transaction failed");

        if (response['success'] == true) {
          amountController.clear();
          pinController.clear();
          searchController.clear();
          receiverAccountId = null;
          searchResults.clear();
        }
      });
    } catch (e) {
      setState(() {
        loading = false;
        message = "Error: $e";
      });
    }
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int?>(
      valueListenable: AppState().currentAccountNotifier,
      builder: (context, accountId, _) {
        if (accountId == null) {
          return const Scaffold(
            body: Center(child: Text("No account selected")),
          );
        }

        return Scaffold(
          appBar: AppBar(title: const Text("Send Money")),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// SENDER ACCOUNT
                Text(
                  "From Account ID: $accountId",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                /// RECEIVER SEARCH
                TextField(
                  controller: searchController,
                  onChanged: searchUsers,
                  decoration: const InputDecoration(
                    labelText: "Search Receiver (Name / Mobile)",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),

                /// SEARCH RESULTS
                if (searchResults.isNotEmpty)
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: searchResults.length,
                    itemBuilder: (_, index) {
                      final user = searchResults[index];
                      return ListTile(
                        title: Text(user['name']),
                        subtitle: Text(user['number'].toString()),
                        onTap: () {
                          setState(() {
                            receiverAccountId = user['id'];
                            searchController.text = user['name'];
                            searchResults.clear();
                          });
                        },
                      );
                    },
                  ),

                const SizedBox(height: 16),

                /// AMOUNT
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Amount",
                    prefixIcon: Icon(Icons.currency_rupee),
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 16),

                /// CATEGORY
                DropdownButtonFormField(
                  value: selectedCategory,
                  items: const [
                    DropdownMenuItem(
                        value: "transfer", child: Text("Transfer")),
                    DropdownMenuItem(
                        value: "payment", child: Text("Payment")),
                    DropdownMenuItem(value: "bill", child: Text("Bill")),
                  ],
                  onChanged: (v) => setState(() => selectedCategory = v!),
                  decoration: const InputDecoration(
                    labelText: "Category",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 16),

                /// PIN
                TextField(
                  controller: pinController,
                  obscureText: true,
                  maxLength: 4,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Transaction PIN",
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 24),

                /// SEND BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: loading ? null : sendTransaction,
                    child: loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Send Money"),
                  ),
                ),

                if (message.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    message,
                    style: TextStyle(
                      color: message.contains("successful")
                          ? Colors.green
                          : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
