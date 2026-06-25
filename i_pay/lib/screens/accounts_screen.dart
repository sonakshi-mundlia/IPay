import 'package:flutter/material.dart';
import '../services/api_service.dart';
import './add_account_screen.dart';
import './pin_reset_screen.dart';
import './transaction_history_screen.dart';
import './check_balance_screen.dart';
import './cibil_score_screen.dart';
import '../app_state.dart';
import '../core/languages/app_localizations.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final apiService = ApiService();
  List accounts = [];
  bool loading = true;
  int? expandedIndex;


  void deleteAccount(int accountId, int index) async {
    final success = await apiService.deleteAccount(accountId);
    if (!mounted) return;

    if (success) {
      setState(() {
        accounts.removeAt(index);
        expandedIndex = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).translate("account_add_failed")))
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchAccounts();
  }

  Future<void> fetchAccounts() async {
    setState(() => loading = true);
    try {
      final List<dynamic> result = await apiService.getAccounts();
      setState(() {
        accounts = result;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  void navigateToAddAccount() async {
    final added = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddAccountScreen()),
    );
    if (added == true) fetchAccounts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppLocalizations.of(context).translate("my_accounts"),
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (accounts.isEmpty)
              Padding(
                padding: EdgeInsets.only(top: 30),
                child: Text(
                  AppLocalizations.of(context).translate("no_accounts_found"),
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ...List.generate(accounts.length, (index) {
              final account = accounts[index];
              final isExpanded = expandedIndex == index;

              return GestureDetector(
                onTap: () {
                  AppState().setAccount(account["id"]);
                  setState(() {
                    expandedIndex = isExpanded ? null : index;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.account_balance,
                              color: Colors.blue,
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              account["bank_name"] ?? AppLocalizations.of(context).translate("unknown_bank"),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(
                            isExpanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            size: 30,
                            color: Colors.blue,
                          ),
                        ],
                      ),
                      if (isExpanded) ...[
                        const Divider(height: 25),
                        Text(
                          "VPA: ${account["vpa_id"] ?? 'N/A'}",
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 20),

                        // BLUE LINKS
                        buildBlueLink("manage_transactions", () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    TransactionHistoryScreen()),
                          );
                        }),
                        buildBlueLink("update_upi_pin", () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => PinResetScreen()),
                          );
                        }),
                        buildBlueLink("check_balance", () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => CheckBalanceScreen()),
                          );
                        }),
                        buildBlueLink("cibil_score", () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => CibilScoreScreen()),
                          );
                        }),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon:
                          const Icon(Icons.delete, color: Colors.white),
                          label: Text(
                            AppLocalizations.of(context).translate("delete_account"),
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            deleteAccount(account["id"], index);
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 20),

            // ADD ACCOUNT BUTTON
            GestureDetector(
              onTap: navigateToAddAccount,
              child: Container(
                width: 200,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 28,
                    ),
                    SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context).translate("add_account"),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // BLUE LINK WIDGET
  Widget buildBlueLink(String key, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: GestureDetector(
        onTap: onTap,
        child: Text(
          AppLocalizations.of(context).translate(key),
          style: const TextStyle(
            color: Colors.blue,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }
}
