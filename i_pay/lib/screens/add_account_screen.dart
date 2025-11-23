import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AddAccountScreen extends StatefulWidget {
  const AddAccountScreen({super.key});

  @override
  State<AddAccountScreen> createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends State<AddAccountScreen> {
  final apiService = ApiService();

  final TextEditingController bankNameController = TextEditingController();
  final TextEditingController vpaController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController accNumberController = TextEditingController();
  final TextEditingController ifscController = TextEditingController();

  bool loading = false;
  String message = "";

  void addAccount() async {
    setState(() => loading = true);

    final bankName = bankNameController.text.trim();
    final vpa = vpaController.text.trim();
    final accountNumber = accNumberController.text.trim();
    final ifsc = ifscController.text.trim();
    final email = emailController.text.trim();
    final mobile = mobileController.text.trim();

    // Validate required fields
    if (bankName.isEmpty || accountNumber.isEmpty || ifsc.isEmpty || vpa.isEmpty) {
      setState(() {
        loading = false;
        message = "Please fill all required fields";
      });
      return;
    }

    final success = await apiService.addAccount(
      bankName: bankNameController.text,
      vpa: vpaController.text,
      accountNumber: accNumberController.text,
      ifsc: ifscController.text,
      email: emailController.text,
      mobile: mobileController.text,
    );


    setState(() {
      loading = false;
      message = success ? "Account added successfully" : "Failed to add account";
    });

    if (success) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Bank Account"),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Bank Account Details",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 20),

                // BANK NAME
                TextField(
                  controller: bankNameController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.account_balance),
                    labelText: "Bank Name",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),

                // ACCOUNT NUMBER
                TextField(
                  controller: accNumberController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.numbers),
                    labelText: "Account Number",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),

                // IFSC CODE
                TextField(
                  controller: ifscController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.code),
                    labelText: "IFSC Code",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),

                // VPA ID
                TextField(
                  controller: vpaController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.link),
                    labelText: "UPI VPA ID",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),

                // MOBILE NUMBER
                TextField(
                  controller: mobileController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.phone),
                    labelText: "Mobile Number",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),

                // EMAIL
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.email),
                    labelText: "Email",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 25),

                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: loading ? null : addAccount,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                      "Add Account",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),

                if (message.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
