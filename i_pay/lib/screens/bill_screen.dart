import 'package:flutter/material.dart';
import 'bill_pay_screen.dart';

class BillsScreen extends StatelessWidget {
  const BillsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bills = [
      "Electricity Bill",
      "Water Bill",
      "Gas Bill",
      "Broadband Bill",
      "Landline Bill",
      "DTH Bill",
      "Society Maintenance",
      "Credit Card Bill"
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Pay Bills"),
        centerTitle: true,
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bills.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 14),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              title: Text(
                bills[index],
                style: const TextStyle(fontSize: 18),
              ),
              trailing: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BillPayScreen(billName: bills[index]),
                    ),
                  );
                },
                child: const Text("Pay"),
              ),
            ),
          );
        },
      ),
    );
  }
}
