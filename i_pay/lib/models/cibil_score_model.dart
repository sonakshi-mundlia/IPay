class CibilModel {
  final int score;
  final String grade; // or category
  final String explanation;
  final String calculation;
  final List<String> pros;
  final List<String> cons;
  final Map<String, String> help; // how_to_check, how_to_improve
  final String lastUpdated;

  CibilModel({
    required this.score,
    required this.grade,
    required this.explanation,
    required this.calculation,
    required this.pros,
    required this.cons,
    required this.help,
    required this.lastUpdated,
  });

  factory CibilModel.fromJson(Map<String, dynamic> json) {
    return CibilModel(
      score: json['score'] ?? 0,
      grade: json['category'] ?? json['grade'] ?? '',
      explanation: json['explanation'] ?? '',
      calculation: json['calculation'] ?? '',
      pros: List<String>.from(json['pros'] ?? []),
      cons: List<String>.from(json['cons'] ?? []),
      help: Map<String, String>.from(json['help'] ?? {}),
      lastUpdated: json['created_at'] ?? json['last_updated'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'grade': grade,
      'explanation': explanation,
      'calculation': calculation,
      'pros': pros,
      'cons': cons,
      'help': help,
      'last_updated': lastUpdated,
    };
  }
}
