class Playlist {
  final String id;
  final String title;
  final String description;
  final List<int> cifraIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  Playlist({
    required this.id,
    required this.title,
    this.description = '',
    required this.cifraIds,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      cifraIds: List<int>.from(json['cifra_ids'] ?? []),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'cifra_ids': cifraIds,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Playlist copyWith({
    String? id,
    String? title,
    String? description,
    List<int>? cifraIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Playlist(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      cifraIds: cifraIds ?? this.cifraIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Método para gerar um ID único baseado em timestamp
  static String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}
