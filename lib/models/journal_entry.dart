
class JournalEntry {
  final String id;
  final String date;
  final String text;
  final String? voicePath;
  final int voiceDuration;
  final int doodleCount;
  final String tagColorHex;

  JournalEntry({
    required this.id,
    required this.date,
    required this.text,
    this.voicePath,
    this.voiceDuration = 0,
    this.doodleCount = 0,
    required this.tagColorHex,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'text': text,
      'voicePath': voicePath,
      'voiceDuration': voiceDuration,
      'doodleCount': doodleCount,
      'tagColorHex': tagColorHex,
    };
  }

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      id: json['id'] as String,
      date: json['date'] as String,
      text: json['text'] as String,
      voicePath: json['voicePath'] as String?,
      voiceDuration: json['voiceDuration'] as int? ?? 0,
      doodleCount: json['doodleCount'] as int? ?? 0,
      tagColorHex: json['tagColorHex'] as String? ?? '#7C6FF7',
    );
  }
}
