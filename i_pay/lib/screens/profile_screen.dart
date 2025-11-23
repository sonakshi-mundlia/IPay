import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'accounts_screen.dart';
import 'help_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final apiService = ApiService();
  Map<String, dynamic> userData = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  void fetchProfile() async {
    final data = await apiService.getProfile(); // API returns user info
    setState(() {
      userData = data;
      loading = false;
    });
  }

  void navigateToAccounts() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AccountScreen()),
    );
  }

  void navigateToHelp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const HelpScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            // PROFILE ICON
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blueAccent,
              child: Icon(Icons.person, size: 60, color: Colors.white),
            ),

            const SizedBox(height: 20),

            // USER INFORMATION CARD
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userData["name"] ?? "User Name",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    ListTile(
                      leading: const Icon(Icons.email, color: Colors.blue),
                      title: const Text("Email"),
                      subtitle: Text(userData['email'] ?? "Not provided"),
                    ),

                    ListTile(
                      leading: const Icon(Icons.phone, color: Colors.green),
                      title: const Text("Phone Number"),
                      subtitle: Text(userData['mobile'] ?? "Not provided"),
                    ),

                    ListTile(
                      leading: const Icon(Icons.account_balance_wallet, color: Colors.deepPurple),
                      title: const Text("VPA Address"),
                      subtitle: Text(userData['vpa'] ?? "Not provided"),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // MY ACCOUNTS CARD
            GestureDetector(
              onTap: navigateToAccounts,
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: const [
                      Icon(Icons.account_balance, size: 32, color: Colors.blue),
                      SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          "My Accounts",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // HELP CENTER CARD
            GestureDetector(
              onTap: navigateToHelp,
              child: Card(
                color: Colors.blue.shade50,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: const [
                      Icon(Icons.help_outline, size: 32, color: Colors.blue),
                      SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          "Help Center",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
