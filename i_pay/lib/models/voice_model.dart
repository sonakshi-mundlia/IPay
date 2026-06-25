class VoiceResponse {
  final String speech;
  final String intent;
  final String? navigate;
  final Map<String, dynamic>? extra;

  VoiceResponse({
    required this.speech,
    required this.intent,
    this.navigate,
    this.extra,
  });

  factory VoiceResponse.fromJson(Map<String, dynamic> json) {
    final rawSpeech = json['speech'];
    final speechSafe = (rawSpeech == null || rawSpeech.toString().trim().isEmpty)
        ? 'Okay.'
        : rawSpeech.toString();

    return VoiceResponse(
      speech: speechSafe,
      intent: json['intent']?.toString() ?? 'NONE',
      navigate: json['navigate']?.toString(),
      extra: json['extra'] as Map<String, dynamic>?,
    );
  }
}
