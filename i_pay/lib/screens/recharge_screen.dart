import 'package:flutter/material.dart';
import 'recharge_pay_screen.dart';

class RechargeScreen extends StatelessWidget {
  const RechargeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final recharges = [
      "Mobile Recharge",
      "FASTag Reload",
      "Metro Card Recharge",
      "Cable TV Recharge",
      "Gaming / OTT",
      "Google Play / App Store"
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Recharges"),
        centerTitle: true,
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: recharges.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 14),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              title: Text(
                recharges[index],
                style: const TextStyle(fontSize: 18),
              ),
              trailing: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          RechargePayScreen(rechargeName: "Mobile Recharge"),
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

