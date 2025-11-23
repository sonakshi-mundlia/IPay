import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/transaction_card.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  final apiService = ApiService();
  List transactions = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchTransactions();
  }

  void fetchTransactions() async {
    final result = await apiService.getTransactionHistory();
    setState(() {
      transactions = result;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Transaction History")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : transactions.isEmpty
          ? const Center(child: Text("No transactions found"))
          : ListView.builder(
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final t = transactions[index];
          final bool isSent = t['from_id'] == apiService.currentUserId;

          return TransactionCard(
            receiver: t['to_name'] ?? t['from_name'] ?? "Unknown",
            amount: t['amount']?.toDouble() ?? 0.0,
            date: t['timestamp'] ?? "",
            isSent: isSent,
          );
        },
      ),
    );
  }
}
