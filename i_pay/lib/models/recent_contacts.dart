class RecentContact {
  final int id;
  final String name;
  final String mobile;

  RecentContact({
    required this.id,
    required this.name,
    required this.mobile,
  });

  String get number => mobile.toString();

  factory RecentContact.fromJson(Map<String, dynamic> json) {
    return RecentContact(
      id: json['id'],
      name: json['name'],
      mobile: json['mobile'],
    );
  }
}