class Transaction {
  final String receiverName;
  final double amount;

  Transaction({required this.receiverName, required this.amount});

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
    receiverName: json['receiver_name'],
    amount: json['amount'].toDouble(),
  );
}
