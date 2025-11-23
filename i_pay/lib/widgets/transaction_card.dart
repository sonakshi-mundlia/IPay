import 'package:flutter/material.dart';

class TransactionCard extends StatelessWidget {
  final String receiver;
  final double amount;
  final String date;
  final bool isSent;

  const TransactionCard({
    super.key,
    required this.receiver,
    required this.amount,
    required this.date,
    required this.isSent,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: ListTile(
        leading: Icon(
          isSent ? Icons.arrow_upward : Icons.arrow_downward,
          color: isSent ? Colors.red : Colors.green,
          size: 30,
        ),
        title: Text(
          "$receiver",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(date),
        trailing: Text(
          "${isSent ? '-' : '+'}₹${amount.toStringAsFixed(2)}",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isSent ? Colors.red : Colors.green,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
