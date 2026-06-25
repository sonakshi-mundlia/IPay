import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/cibil_gauge.dart';
import '../models/cibil_score_model.dart';
import '../app_state.dart';

class CibilScoreScreen extends StatefulWidget {
  const CibilScoreScreen({super.key});

  @override
  State<CibilScoreScreen> createState() => _CibilScoreScreenState();
}

class _CibilScoreScreenState extends State<CibilScoreScreen> {
  final ApiService apiService = ApiService();

  CibilModel? data;
  bool loading = false;
  int? lastAccountId;

  Future<void> _loadCibil(int accountId) async {
    setState(() {
      loading = true;
      data = null;
    });

    try {
      final res = await apiService.getCibilScore(accountId);
      setState(() {
        data = res;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      debugPrint("Error fetching CIBIL: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Your CIBIL Score",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: ValueListenableBuilder<int?>(
        valueListenable: AppState().currentAccountNotifier,
        builder: (context, accountId, _) {
          if (accountId == null) {
            return const Center(child: Text("No account selected"));
          }

          // 🔁 reload when account changes
          if (lastAccountId != accountId) {
            lastAccountId = accountId;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _loadCibil(accountId);
            });
          }

          if (loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (data == null) {
            return const Center(child: Text("Failed to load CIBIL score"));
          }

          final score = data!.score;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                Center(child: CibilGauge(score: score)),

                const SizedBox(height: 10),

                Center(
                  child: Column(
                    children: [
                      Text(
                        "$score",
                        style: const TextStyle(
                            fontSize: 48, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        data!.grade,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                _card("What does this score mean?", data!.explanation),
                _card("Why your score is this", data!.calculation),
                _listCard("Pros", data!.pros),
                _listCard("Cons", data!.cons),
                _helpLinks(data!.help),
              ],
            ),
          );
        },
      ),
    );
  }

  // ================= UI HELPERS =================

  Widget _card(String title, String body) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style:
              const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text(body, style: const TextStyle(fontSize: 16)),
        ]),
      ),
    );
  }

  Widget _listCard(String title, List<String> items) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style:
              const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ...items.map(
                (e) => Text("• $e", style: const TextStyle(fontSize: 16)),
          ),
        ]),
      ),
    );
  }

  Widget _helpLinks(Map<String, String> help) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: help.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("• ", style: TextStyle(fontSize: 16)),
              Expanded(
                child: Text(
                  "${entry.key}: ${entry.value}",
                  style: const TextStyle(fontSize: 16),
                ),
              )
            ],
          ),
        );
      }).toList(),
    );
  }
}
