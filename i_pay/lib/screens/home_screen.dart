import 'package:flutter/material.dart';
import '../services/stt_service.dart';
import '../services/api_service.dart';
import '../app_state.dart';
import 'analytics_screen.dart';
import 'transaction_screen.dart';
import 'transaction_history_screen.dart';
import 'accounts_screen.dart';
import 'profile_screen.dart';
import 'loan_list_screen.dart';
import 'bill_screen.dart';
import 'recharge_screen.dart';
import 'cibil_score_screen.dart';
import 'pay_anyone_screen.dart';
import 'scan_qr_screen.dart';
import 'bank_transaction_screen.dart';
import '../widgets/mic_button.dart';
import '../widgets/pay_box.dart';
import '../widgets/rotating_banner.dart';
import '../models/recent_contacts.dart';
import '../voice/voice_handler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String recognizedText = "";
  String responseText = "";
  bool isListening = false;
  int? selectedAccountId;
  bool loading = true;
  bool _voiceHandled = false;

  int? userId;
  List<RecentContact> _recentContacts = [];

  @override
  void initState() {
    super.initState();
    STTService.onStopCallback = () {
      setState(() {
        isListening = false;
      });
    };

    AppState().currentAccountNotifier.addListener(_onAccountChanged);
  }

  void _onAccountChanged() {
    fetchRecentContacts();
  }

  @override
  void dispose() {
    AppState().currentAccountNotifier.removeListener(_onAccountChanged);
    super.dispose();
  }

  Future<void> fetchRecentContacts() async {
    final int? accountId = AppState().currentAccountId;

    if (accountId == null) return;

    try {
      final data = await ApiService().getRecentContacts(accountId);
      setState(() {
        _recentContacts = data;
      });
    } catch (e) {
      debugPrint("Failed to load contacts: $e");
    }
  }


  Future<void> onMicTap() async {
    // 🛑 Stop if STT is already listening
    if (STTService.isListening) {
      await STTService.stopListening();
      setState(() => isListening = false);
      return;
    }

    _voiceHandled = false;
    setState(() => isListening = true);

    await STTService.startListening((recognizedText) async {
      final text = recognizedText.trim().toLowerCase();
      if (text.isEmpty) return;

      // 🔒 Prevent duplicate navigation
      if (_voiceHandled) return;
      _voiceHandled = true;

      await STTService.stopListening();

      setState(() {
        isListening = false;
      });

      debugPrint("🎙 VOICE FINAL INPUT: $text");

      try {
        final response = await ApiService().processVoiceCommand(text);

        await VoiceHandler.handleRecognition(
          context: context,
          response: response,
        );
      } catch (e) {
        debugPrint("❌ Voice processing error: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to process voice command")),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int?>(
      valueListenable: AppState().currentAccountNotifier,
      builder: (context, accountId, _) {
        if (accountId == null) {
          return Scaffold(
            appBar: AppBar(title: const Text("Home")),
            body: const Center(
              child: Text("Please select an account"),
            ),
          );
        }

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // ---------------- BANNER ----------------
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 300,
                  child: RotatingBanner(),
                ),
              ),

              // ---------------- SPACING ----------------
              SliverToBoxAdapter(child: const SizedBox(height: 10)),

              // ---------------- PAY ACTIONS ----------------
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(2, 16, 2, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Scan QR
                      ActionBox(
                        icon: Icons.qr_code_scanner,
                        title: "Scan QR",
                        color: Colors.blue,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => QRScanScreen()),
                        ),
                      ),

                      // Pay Anyone
                      ActionBox(
                        icon: Icons.person,
                        title: "Pay Anyone",
                        color: Colors.green,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => PayAnyoneScreen()),
                        ),
                      ),

                      // Bank Transfer
                      ActionBox(
                        icon: Icons.account_balance,
                        title: "Bank Transfer",
                        color: Colors.orange,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => BankTransactionScreen()),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ---------------- CONTACTS TITLE ----------------
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: const Text(
                    "Recent Contacts",
                    style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              // ---------------- CONTACT GRID ----------------
              _recentContacts.isEmpty
                  ? SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Text(
                        "No recent transactions.\nStart your first transaction!",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
              )
                  : SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final user = _recentContacts[index];
                      return GestureDetector(
                        onTap: () {
                          if (userId == null) return;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => TransactionScreen()),
                          );
                        },
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 34,
                              backgroundColor: Colors.blueAccent,
                              child: Text(
                                user.name.isNotEmpty
                                    ? user.name[0].toUpperCase()
                                    : "?",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              user.name,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    childCount: _recentContacts.length,
                  ),
                ),
              ),

              // ---------------- LOAN & CIBIL ----------------
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Links row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => LoanListScreen()),
                            ),
                            child: Row(
                              children: const [
                                Text(
                                  "Loans",
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 14,
                                    decoration: TextDecoration.underline,
                                    decorationColor: Colors.blue,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  "→",
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => CibilScoreScreen()),
                            ),
                            child: Row(
                              children: const [
                                Text(
                                  "CIBIL Score",
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 14,
                                    decoration: TextDecoration.underline,
                                    decorationColor: Colors.blue,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  "→",
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Loan & Cibil Cards
                      Row(
                        children: [
                          Expanded(
                            child: _buildCard(
                                image: "assets/images/loan.jpg", title: "Loans"),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildCard(
                                image: "assets/images/cibil_score.jpg",
                                title: "CIBIL Score"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // ---------------- BILLS & RECHARGE ----------------
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => BillsScreen()),
                            ),
                            child: Row(
                              children: const [
                                Text(
                                  "Bills",
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 14,
                                    decoration: TextDecoration.underline,
                                    decorationColor: Colors.blue,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  "→",
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => RechargeScreen()),
                            ),
                            child: Row(
                              children: const [
                                Text(
                                  "Recharge",
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 14,
                                    decoration: TextDecoration.underline,
                                    decorationColor: Colors.blue,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  "→",
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _buildCard(
                                image: "assets/images/bill.jpg", title: "Bills"),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildCard(
                                image: "assets/images/recharge.jpg",
                                title: "Recharges"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // ---------------- BOTTOM SPACING ----------------
              SliverToBoxAdapter(child: const SizedBox(height: 40)),
            ],
          ),

          floatingActionButton: MicButton(
            isListening: isListening,
            onTap: onMicTap,
          ),

          bottomNavigationBar: BottomNavigationBar(
            selectedItemColor: Colors.blue,
            unselectedItemColor: Colors.grey,
            type: BottomNavigationBarType.fixed,
            onTap: (index) {
              switch (index) {
                case 0:
                  break;
                case 1:
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AnalyticsScreen()),
                  );
                  break;
                case 2:
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => TransactionScreen()),
                  );
                  break;
                case 3:
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => TransactionHistoryScreen()),
                  );
                  break;
                case 4:
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AccountScreen()),
                  );
                  break;
                case 5:
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ProfileScreen()),
                  );
                  break;
              }
            },
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
              BottomNavigationBarItem(icon: Icon(Icons.analytics), label: "Analytics"),
              BottomNavigationBarItem(icon: Icon(Icons.send), label: "Transaction"),
              BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
              BottomNavigationBarItem(icon: Icon(Icons.account_balance), label: "Accounts"),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
            ],
          ),
        );
      },
    );
  }

// Helper to avoid repeating card code
  Widget _buildCard({required String image, required String title}) {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            offset: const Offset(0, 3),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: Image.asset(image, fit: BoxFit.contain),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

}
