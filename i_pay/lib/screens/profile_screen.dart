import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../services/api_service.dart';
import '/app_state.dart';
import 'accounts_screen.dart';
import 'help_screen.dart';
import 'pin_reset_screen.dart';
import 'settings_screen.dart';
import 'language_screen.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService apiService = ApiService();
  final AppState appState = AppState();

  Map<String, dynamic> userData = {};
  List<Map<String, dynamic>> accounts = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  // ================= FETCH PROFILE =================
  Future<void> fetchProfile() async {
    setState(() => loading = true);

    debugPrint(
        "📌 Loaded AppState => activeAccountId=${appState.currentAccountId}");

    setState(() {
      accounts = appState.accounts;
      userData = {}; // You can populate from API if needed
      loading = false;
    });
  }

  // ================= ACTIVE ACCOUNT =================
  Map<String, dynamic>? get activeAccount {
    final accountId = appState.currentAccountId;
    if (accountId == null) return null;

    try {
      return accounts.firstWhere((a) => a['id'] == accountId);
    } catch (_) {
      return null;
    }
  }

  // ================= LOGOUT =================
  Future<void> handleLogout() async {
    await apiService.clearToken();
    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (_) => false,
    );
  }

  // ================= QR =================
  void showQr() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final acc = activeAccount;
      final vpa = acc?['vpa_id'];
      final name = userData['name'] ?? "";

      if (vpa == null || vpa.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("VPA not available")),
        );
        return;
      }

      final upiUri = "upi://pay?pa=$vpa&pn=$name";

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Your UPI QR"),
          content: SizedBox(
            width: 260, // fixed width to avoid intrinsic layout errors
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                QrImageView(
                  data: upiUri,
                  size: 220,
                ),
                const SizedBox(height: 12),
                Text(
                  vpa,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        ),
      );
    });
  }

  Widget _tile(IconData icon, String title, VoidCallback onTap,
      {bool destructive = false}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(icon,
                size: 22, color: destructive ? Colors.red : Colors.black87),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: destructive ? Colors.red : Colors.black,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int?>(
      valueListenable: appState.currentAccountNotifier,
      builder: (context, accountId, _) {
        if (loading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (accountId == null) {
          return const Scaffold(
            body: Center(child: Text("No active account selected")),
          );
        }

        return Scaffold(
          appBar: AppBar(title: const Text("Profile")),
          body: SingleChildScrollView(
            child: Column(
              children: [
                // ================= HEADER =================
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 28),
                  color: Colors.blue,
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: showQr,
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            const CircleAvatar(
                              radius: 42,
                              backgroundColor: Colors.white,
                              child: Icon(Icons.person,
                                  size: 46, color: Colors.blue),
                            ),
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.qr_code,
                                  size: 18, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        userData['name'] ?? "",
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      if (activeAccount?['vpa_id'] != null)
                        Text(
                          activeAccount!['vpa_id'],
                          style: const TextStyle(color: Colors.white70),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        userData['email'] ?? "",
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ================= ACCOUNTS =================
                Column(
                  children: accounts.map((acc) {
                    final isActive = acc['id'] == accountId;
                    return InkWell(
                      onTap: () async {
                        setState(() => loading = true);

                        await apiService.setActiveAccount(acc['id']);
                        appState.setAccount(acc['id']);

                        if (!mounted) return;
                        setState(() => loading = false);
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isActive ? Colors.blue : Colors.grey.shade300,
                            width: isActive ? 2 : 1,
                          ),
                          color: isActive
                              ? Colors.blue.withOpacity(0.1)
                              : Colors.white,
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.account_balance,
                                color: isActive ? Colors.blue : Colors.grey),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    acc['bank_name'] ?? "",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isActive
                                          ? Colors.blue
                                          : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    acc['vpa_id'] ?? "",
                                    style: TextStyle(
                                      color: isActive
                                          ? Colors.blue.shade700
                                          : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isActive)
                              const Icon(Icons.check_circle, color: Colors.blue),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 24),

                // ================= OPTIONS =================
                _tile(
                  Icons.account_balance,
                  "Add / Manage Banks",
                      () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AccountScreen()),
                  ),
                ),
                _tile(
                  Icons.lock_reset,
                  "Reset PIN",
                      () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => PinResetScreen()),
                  ),
                ),
                _tile(
                  Icons.settings,
                  "Settings",
                      () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  ),
                ),
                _tile(
                  Icons.language,
                  "Language",
                      () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LanguageScreen()),
                  ),
                ),
                _tile(
                  Icons.help_outline,
                  "Help Center",
                      () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HelpScreen()),
                  ),
                ),
                _tile(Icons.logout, "Log out", handleLogout, destructive: true),

                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }
}
