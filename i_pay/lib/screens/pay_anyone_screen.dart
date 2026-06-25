import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/recent_contacts.dart';
import '../app_state.dart';
import 'transaction_screen.dart';

class PayAnyoneScreen extends StatefulWidget {
  const PayAnyoneScreen({super.key});

  @override
  State<PayAnyoneScreen> createState() => _PayAnyoneScreenState();
}

class _PayAnyoneScreenState extends State<PayAnyoneScreen> {
  String searchQuery = "";
  List<RecentContact> _recentContacts = [];
  bool loading = false;

  int? _lastAccountId;

  Future<void> _fetchRecentContacts(int accountId) async {
    setState(() {
      loading = true;
      _recentContacts = [];
    });

    try {
      final data = await ApiService().getRecentContacts(accountId);

      // If the API already returns a list, just map it
      final contactList = data as List<dynamic>;

      setState(() {
        _recentContacts = contactList
            .map((e) => RecentContact.fromJson(e as Map<String, dynamic>))
            .toList();
        loading = false;
      });
    } catch (e) {
      debugPrint("Failed to load contacts: $e");
      setState(() => loading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pay Anyone"),
      ),
      body: ValueListenableBuilder<int?>(
        valueListenable: AppState().currentAccountNotifier,
        builder: (context, accountId, _) {
          if (accountId == null) {
            return const Center(child: Text("No account selected"));
          }

          // 🔁 Reload when account changes
          if (_lastAccountId != accountId) {
            _lastAccountId = accountId;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _fetchRecentContacts(accountId);
            });
          }

          final filteredContacts = _recentContacts.where((c) {
            final name = c.name.toLowerCase();
            final mobile = c.mobile.toString();
            return name.contains(searchQuery.toLowerCase()) ||
                mobile.contains(searchQuery);
          }).toList();

          if (loading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔍 SEARCH BAR
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    onChanged: (value) =>
                        setState(() => searchQuery = value),
                    decoration: const InputDecoration(
                      icon: Icon(Icons.search),
                      border: InputBorder.none,
                      hintText: "Search name or number",
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "Recent Contacts",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                // 📞 CONTACT LIST
                filteredContacts.isEmpty
                    ? const Expanded(
                  child: Center(
                    child: Text(
                      "No recent contacts",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                )
                    : Expanded(
                  child: ListView.builder(
                    itemCount: filteredContacts.length,
                    itemBuilder: (context, index) {
                      final contact = filteredContacts[index];

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                              const TransactionScreen(),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 14, horizontal: 12),
                          margin:
                          const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                            BorderRadius.circular(10),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundColor:
                                Colors.blue.shade100,
                                child: Text(
                                  contact.name[0],
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 15),
                              Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    contact.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight:
                                      FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    contact.mobile.toString(),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              const Icon(Icons.chevron_right),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
