import 'package:flutter/material.dart';
import '../models/loan_model.dart';
import 'loan_apply_screen.dart'; // Import the apply screen

class LoanListScreen extends StatelessWidget {
  const LoanListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loans = LoanInfo.loanList;

    return Scaffold(
      appBar: AppBar(
        title: const Text("All Loans"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: loans.map((loan) => _buildLoanCard(context, loan)).toList(),
        ),
      ),
    );
  }

  Widget _buildLoanCard(BuildContext context, LoanInfo loan) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          loan.name,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: SizedBox(
          width: 60,
          height: 60,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              loan.image,
              fit: BoxFit.cover,
            ),
          ),
        ),
        children: [
          _buildDetailRow(Icons.currency_rupee, "Loan Amount", loan.loanAmount),
          _buildDetailRow(Icons.credit_card, "Monthly EMI", loan.monthlyEMI),
          _buildDetailRow(Icons.calendar_month, "Loan Period", loan.loanPeriod),
          _buildDetailRow(Icons.percent, "Interest Rate", loan.interestRate),
          _buildDetailRow(Icons.star, "Minimum Credit Score", loan.minCreditScore.toString()),
          const SizedBox(height: 8),
          _buildListSection(Icons.description, "Documents Needed", loan.documents),
          const SizedBox(height: 8),
          _buildListSection(Icons.verified, "Eligibility", loan.eligibility),
          const SizedBox(height: 12),
          Center(
            child: ElevatedButton(
              onPressed: () {
                // Navigate to LoanApplyScreen with selected loan
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LoanApplyScreen(loan: loan),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "Apply Now",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 22, color: Colors.blue),
          const SizedBox(width: 8),
          Text(
            "$label: ",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildListSection(IconData icon, String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 22, color: Colors.blue),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: items
              .map((item) => Padding(
            padding: const EdgeInsets.only(left: 30, bottom: 2),
            child: Text("• $item"),
          ))
              .toList(),
        ),
      ],
    );
  }
}
