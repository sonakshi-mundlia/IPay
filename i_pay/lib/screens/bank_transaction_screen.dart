import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/bank_account_model.dart';
import '../app_state.dart';

class BankTransactionScreen extends StatefulWidget {
  const BankTransactionScreen({super.key});

  @override
  State<BankTransactionScreen> createState() => _BankTransactionScreenState();
}

class _BankTransactionScreenState extends State<BankTransactionScreen> {
  final ApiService apiService = ApiService();

  List<BankAccount> accounts = [];
  BankAccount? selectedAccount;

  final TextEditingController accountNameController = TextEditingController();
  final TextEditingController accountNumberController = TextEditingController();
  final TextEditingController ifscController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController pinController = TextEditingController();

  String selectedCategory = "transfer";
  bool loading = false;
  String message = "";

  @override
  void initState() {
    super.initState();

    /// Listen to account changes
    AppState().currentAccountNotifier.addListener(_onAccountChanged);

    /// Initial load
    _loadAccounts();
  }

  @override
  void dispose() {
    AppState().currentAccountNotifier.removeListener(_onAccountChanged);
    super.dispose();
  }

  void _onAccountChanged() {
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    final activeAccountId = AppState().currentAccountNotifier.value;
    if (activeAccountId == null) return;

    try {
      final data = await apiService.getUserBankAccounts(
        excludeAccountId: activeAccountId,
      );

      setState(() {
        accounts = data;
        selectedAccount = null;
        _clearSelectedAccountFields();
      });
    } catch (e) {
      debugPrint("Error loading accounts: $e");
    }
  }

  void _clearSelectedAccountFields() {
    accountNameController.clear();
    accountNumberController.clear();
    ifscController.clear();
  }

  void onAccountSelected(BankAccount? account) {
    if (account == null) return;

    setState(() {
      selectedAccount = account;
      accountNameController.text = account.accountName;
      accountNumberController.text = account.accountNumber;
      ifscController.text = account.ifsc;
    });
  }

  Future<void> sendTransaction(int activeAccountId) async {
    if (selectedAccount == null) {
      setState(() => message = "Please select a bank account");
      return;
    }

    final amount = double.tryParse(amountController.text.trim()) ?? 0;
    final pin = pinController.text.trim();

    if (amount <= 0 || pin.length != 4) {
      setState(() => message = "Enter valid amount and 4-digit PIN");
      return;
    }

    setState(() {
      loading = true;
      message = "";
    });

    try {
      await apiService.sendTransaction(
        fromAccountId: activeAccountId,
        toAccountId: selectedAccount!.id,
        amount: amount,
        pin: pin,
        category: selectedCategory,
      );

      setState(() {
        message = "Transaction successful";
        amountController.clear();
        pinController.clear();
      });
    } catch (e) {
      debugPrint("Transaction error: $e");
      setState(() => message = "Transaction failed");
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int?>(
      valueListenable: AppState().currentAccountNotifier,
      builder: (context, activeAccountId, _) {
        if (activeAccountId == null) {
          return const Scaffold(
            body: Center(child: Text("No active account selected")),
          );
        }

        return Scaffold(
          appBar: AppBar(title: const Text("Bank Transfer")),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                DropdownButtonFormField<BankAccount>(
                  hint: const Text("Select Bank Account"),
                  value: selectedAccount,
                  items: accounts.map((acc) {
                    return DropdownMenuItem(
                      value: acc,
                      child: Text(acc.bankName),
                    );
                  }).toList(),
                  onChanged: onAccountSelected,
                  decoration:
                  const InputDecoration(border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),

                _readonlyField("Account Name", accountNameController),
                _readonlyField("Account Number", accountNumberController),
                _readonlyField("IFSC Code", ifscController),

                _editableField("Amount", amountController),
                _editableField("PIN", pinController, obscure: true),

                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  items: const [
                    DropdownMenuItem(
                        value: "transfer", child: Text("Transfer")),
                    DropdownMenuItem(
                        value: "bill", child: Text("Bill Payment")),
                    DropdownMenuItem(
                        value: "shopping", child: Text("Shopping")),
                  ],
                  onChanged: (val) =>
                      setState(() => selectedCategory = val!),
                  decoration: const InputDecoration(
                    labelText: "Category",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: loading
                      ? null
                      : () => sendTransaction(activeAccountId),
                  child: loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Pay Now"),
                ),

                if (message.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    message,
                    style: TextStyle(
                      color: message.contains("success")
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  // ================= UI HELPERS =================

  Widget _readonlyField(
      String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _editableField(
      String label, TextEditingController controller,
      {bool obscure = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
