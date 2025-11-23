import 'package:flutter/material.dart';
import '../services/api_service.dart';

class SimpleAnalyticsReport extends StatefulWidget {
  const SimpleAnalyticsReport({super.key});

  @override
  State<SimpleAnalyticsReport> createState() => _SimpleAnalyticsReportState();
}

class _SimpleAnalyticsReportState extends State<SimpleAnalyticsReport> {
  final ApiService apiService = ApiService();
  Map<String, dynamic> data = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchAnalytics();
  }

  void fetchAnalytics() async {
    try {
      final fetchedData = await apiService.getAnalytics();
      setState(() {
        data = fetchedData;
        loading = false;
      });
    } catch (e) {
      setState(() {
        data = {};
        loading = false;
      });
      debugPrint("Failed to fetch analytics: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (data.isEmpty) {
      return const Center(child: Text("No analytics data available."));
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _summaryRow("Total Sent", "₹${data['total_sent'] ?? 0}", Colors.red),
              const SizedBox(height: 10),
              _summaryRow("Total Received", "₹${data['total_received'] ?? 0}", Colors.green),
              const SizedBox(height: 10),
              _summaryRow("Transactions", "${data['num_transactions'] ?? 0}", Colors.blue),
              if (data['category'] != null) ...[
                const SizedBox(height: 10),
                _summaryRow("Top Category", "${data['category']}", Colors.orange),
              ],
              if (data['description'] != null) ...[
                const SizedBox(height: 10),
                _summaryRow("Recommendation", "${data['description']}", Colors.purple),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryRow(String title, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}
