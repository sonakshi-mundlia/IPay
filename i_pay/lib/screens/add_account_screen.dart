import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../core/languages/app_localizations.dart';

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
  final TextEditingController pinController = TextEditingController();
  final TextEditingController balanceController = TextEditingController();

  bool loading = false;
  String message = "";
  bool isFirstAccount = true;
  bool loadingAccounts = true;
  bool isSuccess = false;

  @override
  void initState() {
    super.initState();
    checkIfFirstAccount();
  }

  Future<void> checkIfFirstAccount() async {
    try {
      final count = await apiService.getAccountCount();
      if (!mounted) return;

      setState(() {
        isFirstAccount = count == 0;
        loadingAccounts = false;
      });
    } catch (e) {
      loadingAccounts = false;
    }
  }


  void addAccount() async {
    setState(() {
      loading = true;
      message = "";
      isSuccess = false;
    });

    final bankName = bankNameController.text.trim();
    final vpa = vpaController.text.trim();
    final accountNumber = accNumberController.text.trim();
    final ifsc = ifscController.text.trim();

    if (bankName.isEmpty || accountNumber.isEmpty || ifsc.isEmpty ||
        vpa.isEmpty) {
      setState(() {
        loading = false;
        message = AppLocalizations.of(context)
            .translate("fill_required_fields");
      });
      return;
    }

    final int? accountId = await apiService.addAccount(
      bankName: bankNameController.text,
      vpa: vpaController.text,
      accountNumber: accNumberController.text,
      ifsc: ifscController.text,
      balance: double.tryParse(balanceController.text.trim()) ?? 0.0,
      email: emailController.text,
      mobile: mobileController.text,
      pin: isFirstAccount ? pinController.text : null,
    );

    if (!mounted) return;

    setState(() {
      loading = false;
      isSuccess = accountId != null;
      message = isSuccess
          ? AppLocalizations.of(context).translate("account_added_successfully")
          : AppLocalizations.of(context).translate("account_add_failed");
    });

    if (accountId != null) {
      bankNameController.clear();
      vpaController.clear();
      emailController.clear();
      mobileController.clear();
      accNumberController.clear();
      ifscController.clear();
      pinController.clear();
      balanceController.clear();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate("add_bank_account")),
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
                Text(AppLocalizations.of(context).translate(
                  "bank_account_details"),
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 20),

                // BANK NAME
                TextField(
                  controller: bankNameController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.account_balance),
                    labelText: AppLocalizations.of(context).translate("bank_name"),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),

                // ACCOUNT NUMBER
                TextField(
                  controller: accNumberController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.numbers),
                    labelText: AppLocalizations.of(context).translate("account_number"),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),

                // IFSC CODE
                TextField(
                  controller: ifscController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.code),
                    labelText: AppLocalizations.of(context).translate("ifsc_code"),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),

                // VPA ID
                TextField(
                  controller: vpaController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.link),
                    labelText: AppLocalizations.of(context).translate("upi_vpa_id"),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),

                // MOBILE NUMBER
                TextField(
                  controller: mobileController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.phone),
                    labelText: AppLocalizations.of(context).translate("mobile_number"),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),

                // EMAIL
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.email),
                    labelText: AppLocalizations.of(context).translate("email"),
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 25),
                // BALANCE
                TextField(
                  controller: balanceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.currency_rupee),
                    labelText: AppLocalizations.of(context).translate("balance_optional"),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),

                // PIN
                if (isFirstAccount) ...[
                  const SizedBox(height: 15),

                  TextField(
                    controller: pinController,
                    obscureText: true,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.lock),
                      labelText: AppLocalizations.of(context).translate("transaction_pin"),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],

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
                        : Text(AppLocalizations.of(context).translate("add_account"),
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
