import 'package:flutter/material.dart';
import '../models/loan_model.dart';

class LoanApplyScreen extends StatefulWidget {
  final LoanInfo loan;

  const LoanApplyScreen({super.key, required this.loan});

  @override
  State<LoanApplyScreen> createState() => _LoanApplyScreenState();
}

class _LoanApplyScreenState extends State<LoanApplyScreen> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController nameController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController periodController = TextEditingController();
  TextEditingController interestController = TextEditingController();
  TextEditingController creditScoreController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final loan = widget.loan;

    return Scaffold(
      appBar: AppBar(
        title: Text("Apply for ${loan.name}"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: const Offset(0, 3),
              )
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // ----------------- APPLICATION FORM -----------------
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: "Your Name",
                    hintText: "Please enter your name",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                  value!.isEmpty ? "Please enter your name" : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: amountController,
                  decoration: const InputDecoration(
                    labelText: "Loan Amount",
                    hintText: "Please enter loan amount",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                  value!.isEmpty ? "Please enter loan amount" : null,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: periodController,
                  decoration: const InputDecoration(
                    labelText: "Loan Period",
                    hintText: "Please enter loan period",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                  value!.isEmpty ? "Please enter loan period" : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: interestController,
                  decoration: const InputDecoration(
                    labelText: "Interest Rate",
                    hintText: "Please enter interest rate",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                  value!.isEmpty ? "Please enter interest rate" : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: creditScoreController,
                  decoration: const InputDecoration(
                    labelText: "CIBIL Score",
                    hintText: "Please enter your CIBIL score",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.isEmpty) return "Please enter your CIBIL score";
                    final score = int.tryParse(value);
                    if (score == null) return "Invalid number";
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  "Application submitted for ${loan.name}")),
                        );
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 14),
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text(
                      "Submit Application",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
