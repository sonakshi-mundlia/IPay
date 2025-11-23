class Analytics {
  final double totalSent;
  final double totalReceived;
  final int numTransactions;
  final String? category;
  final String? description;

  Analytics({
    required this.totalSent,
    required this.totalReceived,
    required this.numTransactions,
    this.category,
    this.description,
  });

  factory Analytics.fromJson(Map<String, dynamic> json) => Analytics(
    totalSent: json['total_sent'].toDouble(),
    totalReceived: json['total_received'].toDouble(),
    numTransactions: json['num_transactions'],
    category: json['category'],
    description: json['description'],
  );
}
