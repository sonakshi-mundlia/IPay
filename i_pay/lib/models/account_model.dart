class Account {
  final int id;
  final int userId;
  final double balance;
  final String vpaId;

  Account({required this.id, required this.userId, required this.balance, required this.vpaId});

  factory Account.fromJson(Map<String, dynamic> json) => Account(
    id: json['id'],
    userId: json['user_id'],
    balance: json['balance'].toDouble(),
    vpaId: json['vpa_id'],
  );
}
