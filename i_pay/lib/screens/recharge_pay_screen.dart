import 'package:flutter/material.dart';

class RechargePayScreen extends StatefulWidget {
  final String rechargeName;

  const RechargePayScreen({super.key, required this.rechargeName});

  @override
  State<RechargePayScreen> createState() => _RechargePayScreenState();
}

class _RechargePayScreenState extends State<RechargePayScreen> {
  late TextEditingController numberController;
  late TextEditingController amountController;

  bool loading = false;

  @override
  void initState() {
    super.initState();
    numberController = TextEditingController();
    amountController = TextEditingController();
  }

  @override
  void dispose() {
    numberController.dispose();
    amountController.dispose();
    super.dispose();
  }

  void _proceedPayment() {
    final number = numberController.text.trim();
    final amount = amountController.text.trim();

    if (number.isEmpty || amount.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all fields"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final double? amt = double.tryParse(amount);
    if (amt == null || amt <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Enter a valid amount"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => loading = true);

    // Simulate payment request delay
    Future.delayed(const Duration(seconds: 1), () {
      setState(() => loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Payment Request Accepted!"),
          backgroundColor: Colors.green,
        ),
      );

      // Optionally clear fields
      numberController.clear();
      amountController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.rechargeName),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 5,
                offset: Offset(0, 3),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Recharge Type: ${widget.rechargeName}",
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Number / Card ID
              TextField(
                controller: numberController,
                decoration: const InputDecoration(
                  labelText: "Number / Card ID",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              // Amount
              TextField(
                controller: amountController,
                decoration: const InputDecoration(
                  labelText: "Amount",
                  border: OutlineInputBorder(),
                ),
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 30),

              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: loading ? null : _proceedPayment,
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 14)),
                    child: loading
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Text("Proceed to Pay"),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
