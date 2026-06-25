import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/api_service.dart';
import '../app_state.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final ApiService apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Analytics Dashboard"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ValueListenableBuilder<int?>(
        valueListenable: AppState().currentAccountNotifier,
        builder: (context, accountId, _) {
          if (accountId == null) {
            return const Center(child: Text("No account selected"));
          }

          return FutureBuilder<Map<String, dynamic>>(
            future: apiService.getAnalytics(accountId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              }

              final data = snapshot.data!;
              final income = (data['total_income'] ?? 0).toDouble();
              final expense = (data['total_expense'] ?? 0).toDouble();
              final net = (data['net_cash_flow'] ?? 0).toDouble();
              final categorySummary =
              Map<String, double>.from(data['category_summary'] ?? {});
              final patterns = data['patterns'] ?? {};
              final fraudAlerts =
              List<Map<String, dynamic>>.from(data['fraud_alerts'] ?? []);

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _kpiCards(income, expense, net),
                    const SizedBox(height: 20),

                    _title("Cash Flow"),
                    _cashFlowChart(income, expense, net),
                    const SizedBox(height: 12),
                    _cashHealthIndicator(net),
                    const SizedBox(height: 24),

                    _title("Category Summary"),
                    _categoryPieChart(categorySummary),
                    const SizedBox(height: 24),

                    _title("Income & Expense Patterns"),
                    _patternsList(patterns),
                    const SizedBox(height: 24),

                    _title("Financial Health"),
                    _financialIndicators(data),
                    const SizedBox(height: 24),

                    if (fraudAlerts.isNotEmpty) ...[
                      _title("Fraud Alerts"),
                      _fraudAlerts(fraudAlerts),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ===================== COMMON =====================

  Widget _title(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    ),
  );

  // ===================== KPI CARDS =====================

  Widget _kpiCards(double income, double expense, double net) {
    return Row(
      children: [
        _kpiCard("Income", income, Colors.green),
        _kpiCard("Expense", expense, Colors.red),
        _kpiCard("Net", net, net >= 0 ? Colors.blue : Colors.orange),
      ],
    );
  }

  Widget _kpiCard(String title, double value, Color color) {
    return Expanded(
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Text(title,
                  style:
                  TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              const SizedBox(height: 8),
              Text(
                "₹${value.toStringAsFixed(0)}",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===================== BAR CHART =====================

  Widget _cashFlowChart(double income, double expense, double net) {
    final maxY =
        [income, expense, net].reduce((a, b) => a > b ? a : b) * 1.2;

    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          maxY: maxY == 0 ? 10 : maxY,
          barGroups: [
            _bar(0, income, Colors.green),
            _bar(1, expense, Colors.red),
            _bar(2, net, Colors.blue),
          ],
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  switch (value.toInt()) {
                    case 0:
                      return const Text("Income");
                    case 1:
                      return const Text("Expense");
                    case 2:
                      return const Text("Net");
                  }
                  return const SizedBox();
                },
              ),
            ),
            leftTitles:
            AxisTitles(sideTitles: SideTitles(showTitles: true)),
            rightTitles:
            AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
            AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
        ),
      ),
    );
  }

  BarChartGroupData _bar(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          width: 22,
          color: color,
          borderRadius: BorderRadius.circular(6),
        )
      ],
    );
  }

  // ===================== HEALTH INDICATOR =====================

  Widget _cashHealthIndicator(double net) {
    late String label;
    late Color color;
    late IconData icon;

    if (net > 0) {
      label = "Healthy Cash Flow";
      color = Colors.green;
      icon = Icons.trending_up;
    } else if (net == 0) {
      label = "Neutral";
      color = Colors.blueGrey;
      icon = Icons.horizontal_rule;
    } else {
      label = "Overspending Alert";
      color = Colors.red;
      icon = Icons.trending_down;
    }

    return Card(
      color: color.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(label,
            style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        subtitle: Text("Net balance: ₹${net.toStringAsFixed(0)}"),
      ),
    );
  }

  // ===================== PIE CHART =====================

  Widget _categoryPieChart(Map<String, double> categories) {
    if (categories.isEmpty) {
      return const Text("No category data available");
    }

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 240,
          child: PieChart(
            PieChartData(
              sectionsSpace: 3,
              centerSpaceRadius: 50,
              sections: categories.entries.map((e) {
                return PieChartSectionData(
                  title: e.key,
                  value: e.value.abs(),
                  radius: 70,
                  titleStyle: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  // ===================== PATTERNS =====================

  Widget _patternsList(Map<String, dynamic> patterns) {
    if (patterns.isEmpty) {
      return const Text("No transaction patterns detected.");
    }

    return Column(
      children: patterns.entries.map((entry) {
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.key.toUpperCase(),
                    style:
                    const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...List<Map<String, dynamic>>.from(entry.value).map((item) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                        "• ${item['category']}  ₹${item['amount']}"),
                  );
                }),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ===================== FINANCIAL HEALTH =====================

  Widget _financialIndicators(Map<String, dynamic> data) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                "Debt to Income Ratio: ${(data['debt_to_income_ratio'] ?? 0).toStringAsFixed(2)}"),
            Text(
                "Savings Rate: ${(data['savings_rate'] ?? 0).toStringAsFixed(2)}"),
            Text(
                "Average Daily Balance: ₹${(data['avg_daily_balance'] ?? 0).toStringAsFixed(2)}"),
          ],
        ),
      ),
    );
  }

  // ===================== FRAUD ALERTS =====================

  Widget _fraudAlerts(List<Map<String, dynamic>> alerts) {
    return Column(
      children: alerts.map((alert) {
        return Card(
          color: Colors.red.shade50,
          child: ListTile(
            leading: const Icon(Icons.warning, color: Colors.red),
            title: Text("₹${alert['amount']} • ${alert['category']}"),
            subtitle: Text(alert['date']),
            trailing: Chip(
              label: Text(alert['message']),
              backgroundColor: Colors.red.shade100,
            ),
          ),
        );
      }).toList(),
    );
  }
}

