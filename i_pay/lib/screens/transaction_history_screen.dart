import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../app_state.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  final apiService = ApiService();
  List transactions = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    // Listen for account changes
    AppState().currentAccountNotifier.addListener(_onAccountChanged);
    _loadTransactions();
  }

  @override
  void dispose() {
    AppState().currentAccountNotifier.removeListener(_onAccountChanged);
    super.dispose();
  }

  void _onAccountChanged() {
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final accountId = AppState().currentAccountId;
    if (accountId == null) {
      setState(() {
        transactions = [];
        loading = false;
      });
      return;
    }

    setState(() => loading = true);

    try {
      final result = await apiService.getTransactionHistory(accountId: accountId);

      // Only transactions related to this account
      final filtered = result
          .where((t) =>
      t['from_account_id'] == accountId ||
          t['to_account_id'] == accountId)
          .toList();

      setState(() {
        transactions = filtered;
        loading = false;
      });
    } catch (e) {
      debugPrint("Error fetching transactions: $e");
      setState(() => loading = false);
    }
  }

  String formatDateTime(String timestamp) {
    try {
      final dt = DateTime.parse(timestamp);
      return "${dt.day.toString().padLeft(2,'0')}-${dt.month.toString().padLeft(2,'0')}-${dt.year} "
          "${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}";
    } catch (_) {
      return timestamp;
    }
  }

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
          appBar: AppBar(title: const Text("Transaction History")),
          body: loading
              ? const Center(child: CircularProgressIndicator())
              : transactions.isEmpty
              ? const Center(child: Text("No transactions found"))
              : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final t = transactions[index];
              final bool isDebit = t['from_account_id'] == accountId;
              final amount = t['amount']?.toDouble() ?? 0.0;
              final displayAmount = isDebit ? -amount : amount;

              final senderName = t['from_name'] ?? 'Unknown';
              final senderVpa = t['from_vpa'] ?? 'N/A';
              final receiverName = t['to_name'] ?? 'Unknown';
              final receiverVpa = t['to_vpa'] ?? 'N/A';
              final dateTime = formatDateTime(t['timestamp'] ?? "");

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Sender Row
                      Row(
                        children: [
                          const Icon(Icons.arrow_upward,
                              color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "From: $senderName",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Text(
                            senderVpa,
                            style:
                            const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Receiver Row
                      Row(
                        children: [
                          const Icon(Icons.arrow_downward,
                              color: Colors.green),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "To: $receiverName",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Text(
                            receiverVpa,
                            style:
                            const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Date & Amount Row
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            dateTime,
                            style:
                            const TextStyle(color: Colors.grey),
                          ),
                          Text(
                            "${displayAmount < 0 ? '-' : '+'}₹${displayAmount.abs().toStringAsFixed(2)}",
                            style: TextStyle(
                              color: isDebit ? Colors.red : Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
