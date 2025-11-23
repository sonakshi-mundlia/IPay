import 'package:flutter/material.dart';
import '../services/stt_service.dart';
import '../services/tts_service.dart';
import '../services/api_service.dart';
import 'analytics_screen.dart';
import 'transaction_screen.dart';
import 'transaction_history_screen.dart';
import 'accounts_screen.dart';
import 'profile_screen.dart';
import 'pin_setup_screen.dart';
import 'help_screen.dart';

import '../widgets/mic_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String recognizedText = "";
  String responseText = "";
  bool isListening = false;

  int _currentIndex = 0;

  final List<Widget> _screens = const [
    SimpleAnalyticsReport(),
    TransactionScreen(),
    TransactionHistoryScreen(),
    AccountScreen(),
    ProfileScreen(),
  ];

  // LISTEN TO VOICE
  Future<void> startListening() async {
    setState(() => isListening = true);

    await STTService.startListening((text) async {
      recognizedText = text;

      if (text.isNotEmpty) {
        await STTService.stopListening();

        final reply = await ApiService().processVoiceCommand(text);

        setState(() {
          responseText = reply;
          isListening = false;
        });

        await TTSService.speak(reply);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      // ------------------------ APP BAR -----------------------
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        leading: IconButton(
          icon: const Icon(Icons.person, color: Colors.black, size: 32),
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()));
          },
        ),

        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.black, size: 28),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const HelpScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.lock, color: Colors.black, size: 28),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const PinSetupScreen()));
            },
          ),
          const SizedBox(width: 10),
        ],
      ),

      // -------------------------- BODY -------------------------
      body: Column(
        children: [
          // -------------------- TOP HALF BANNER IMAGE --------------------
          Container(
            height: MediaQuery.of(context).size.height * 0.32,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: const DecorationImage(
                image: AssetImage("assets/transaction_banner.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ---------------------- VOICE INPUT + OUTPUT ---------------------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("You Said:",
                    style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(recognizedText, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 10),

                const Text("Assistant:",
                    style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(responseText, style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),

          const SizedBox(height: 20),
          const Divider(),

          // ---------------------- DASHBOARD ---------------------
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Text(
                "Your Dashboard",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          const SizedBox(height: 12),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  dashboardItem(Icons.analytics, "Analytics", 0),
                  dashboardItem(Icons.payment, "Make Transaction", 1),
                  dashboardItem(Icons.history, "History", 2),
                  dashboardItem(Icons.account_balance, "Accounts", 3),
                  dashboardItem(Icons.person, "Profile", 4),

                  const SizedBox(height: 12),

                  // SCREEN PREVIEW
                  SizedBox(
                    height: 300,
                    child: _screens[_currentIndex],
                  )
                ],
              ),
            ),
          ),
        ],
      ),

      // --------------------- MIC BUTTON ------------------------
      floatingActionButton: MicButton(
        isListening: isListening,
        onTap: startListening,
      ),

      // --------------------- BOTTOM NAV ------------------------
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.analytics), label: "Analytics"),
          BottomNavigationBarItem(
              icon: Icon(Icons.send), label: "Transaction"),
          BottomNavigationBarItem(
              icon: Icon(Icons.history), label: "History"),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_balance), label: "Accounts"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  // -------------------- DASHBOARD CARD WIDGET ----------------------
  Widget dashboardItem(IconData icon, String title, int index) {
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 7),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
                color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 30, color: Colors.blueAccent),
            const SizedBox(width: 16),
            Text(title,
                style:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
