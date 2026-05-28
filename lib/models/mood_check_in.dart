class MoodCheckIn {
  final String date;
  final int mentalEnergy;
  final int physicalEnergy;
  final int socialEnergy;
  final List<String> emotions;
  final Map<String, int> emotionIntensities;

  MoodCheckIn({
    required this.date,
    required this.mentalEnergy,
    required this.physicalEnergy,
    required this.socialEnergy,
    required this.emotions,
    required this.emotionIntensities,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'mentalEnergy': mentalEnergy,
      'physicalEnergy': physicalEnergy,
      'socialEnergy': socialEnergy,
      'emotions': emotions,
      'emotionIntensities': emotionIntensities,
    };
  }

  factory MoodCheckIn.fromJson(Map<String, dynamic> json) {
    return MoodCheckIn(
      date: json['date'] as String,
      mentalEnergy: json['mentalEnergy'] as int? ?? 50,
      physicalEnergy: json['physicalEnergy'] as int? ?? 50,
      socialEnergy: json['socialEnergy'] as int? ?? 50,
      emotions: List<String>.from(json['emotions'] as List? ?? []),
      emotionIntensities: Map<String, int>.from(json['emotionIntensities'] as Map? ?? {}),
    );
  }
}
