import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../screens/add_account_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final apiService = ApiService();
  List accounts = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchAccounts();
  }

  void fetchAccounts() async {
    final result = await apiService.getAccounts();
    setState(() {
      accounts = result;
      loading = false;
    });
  }

  void navigateToAddAccount() async {
    final added = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddAccountScreen()),
    );
    if (added == true) {
      fetchAccounts(); // refresh after adding
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Accounts"),
        centerTitle: true,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : accounts.isEmpty
          ? const Center(child: Text("No accounts found"))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// 🔹 All Accounts as Big Cards
            ...accounts.map((account) {
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Bank Icon
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.account_balance,
                        size: 30,
                        color: Colors.blue,
                      ),
                    ),

                    const SizedBox(width: 16),

                    /// Bank Account Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// Bank name
                          Text(
                            account['bank_name'] ?? "Unknown Bank",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 8),

                          /// Account Number
                          Text(
                            "A/C No: ${account['account_number'] ?? 'N/A'}",
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),

                          const SizedBox(height: 4),

                          /// IFSC
                          Text(
                            "IFSC: ${account['ifsc'] ?? 'N/A'}",
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),

                          const SizedBox(height: 4),

                          /// VPA ID
                          Text(
                            "VPA: ${account['vpa_id'] ?? 'N/A'}",
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),

                          const SizedBox(height: 6),

                          /// Balance
                          Text(
                            "Balance: ₹${account['balance'] ?? '0'}",
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),

            const SizedBox(height: 15),

            /// 🔹 Add Bank Account (Bottom Button)
            GestureDetector(
              onTap: navigateToAddAccount,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.green),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add_business_rounded,
                        size: 28,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      "Add Bank Account",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

}