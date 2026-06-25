class BankAccount {
  final String bankName;
  final int id;
  final String accountName;
  final String accountNumber;
  final String ifsc;

  BankAccount({
    required this.bankName,
    required this.id,
    required this.accountName,
    required this.accountNumber,
    required this.ifsc,
  });

  factory BankAccount.fromJson(Map<String, dynamic> json) {
    return BankAccount(
      bankName: json['bank_name'] ?? "",
      id: json['id'],
      accountName: json['account_name'] ?? json['user_name'] ?? "",
      accountNumber: json['account_number']?.toString() ?? "",
      ifsc: json['ifsc_code'] ?? "",
    );
  }
}
