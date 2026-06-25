import 'package:flutter/material.dart';
import 'profile_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        children: [
          // ================= PERSONAL INFO =================
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("Personal Information"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProfileScreen(),
                ),
              );
            },
          ),

          const Divider(height: 1),

          // ================= NOTIFICATIONS =================
          SwitchListTile(
            secondary: const Icon(Icons.notifications),
            title: const Text("Notifications"),
            value: notificationsEnabled,
            onChanged: (value) {
              setState(() {
                notificationsEnabled = value;
              });
            },
          ),

          const Divider(height: 1),

          // ================= ABOUT APP =================
          _expandableSection(
            icon: Icons.info_outline,
            title: "About App",
            image: "assets/icon/app_icon.png",
            content:
            "iPay is a secure UPI-based digital payments application. "
                "It allows users to send and receive money instantly using "
                "bank accounts with full encryption and RBI-compliant security.",
          ),

          // ================= PRIVACY POLICY =================
          _expandableSection(
            icon: Icons.privacy_tip,
            title: "Privacy Policy",
            image: "assets/images/privacy.jpg",
            content:
            "We respect your privacy. All user data is encrypted and "
                "stored securely. We do not sell or share personal data "
                "with third parties under any circumstances.",
          ),

          // ================= TERMS & CONDITIONS =================
          _expandableSection(
            icon: Icons.description,
            title: "Terms & Conditions",
            image: "assets/images/terms.jpg",
            content:
            "By using iPay, you agree to comply with UPI guidelines, "
                "banking rules, and all applicable laws. Misuse may result "
                "in account suspension or termination.",
          ),
        ],
      ),
    );
  }

  // ================= EXPANDABLE SECTION =================
  Widget _expandableSection({
    required IconData icon,
    required String title,
    required String image,
    required String content,
  }) {
    return ExpansionTile(
      leading: Icon(icon),
      title: Text(title),
      childrenPadding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      children: [
        Image.asset(
          image,
          height: 120,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: const TextStyle(fontSize: 14, height: 1.5),
        ),
      ],
    );
  }
}
