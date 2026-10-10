class Playlist {
  final String id;
  final String title;
  final String description;
  final List<int> cifraIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Código da playlist na API (ex.: K7P2QX). Nulo = ainda só local.
  final String? remoteCode;

  /// 'private' (só com o código) ou 'church' (aparece para todos).
  final String visibility;

  /// Data do culto (yyyy-MM-dd). Obrigatória para publicar para a igreja.
  final String? serviceDate;

  /// Observação por cifra: "tom G", "só 2 estrofes"...
  final Map<int, String> cifraNotes;

  /// Tem alteração local que ainda não chegou na API (ex.: estava offline).
  final bool pendingSync;

  Playlist({
    required this.id,
    required this.title,
    this.description = '',
    required this.cifraIds,
    required this.createdAt,
    required this.updatedAt,
    this.remoteCode,
    this.visibility = 'private',
    this.serviceDate,
    this.cifraNotes = const {},
    this.pendingSync = false,
  });

  bool get isRemote => remoteCode != null && remoteCode!.isNotEmpty;
  bool get isPublishedToChurch => isRemote && visibility == 'church';

  DateTime? get serviceDateValue =>
      serviceDate == null ? null : DateTime.tryParse(serviceDate!);

  factory Playlist.fromJson(Map<String, dynamic> json) {
    final rawNotes = json['cifra_notes'];
    final notes = <int, String>{};
    if (rawNotes is Map) {
      rawNotes.forEach((key, value) {
        final id = int.tryParse(key.toString());
        if (id != null && value is String && value.isNotEmpty) {
          notes[id] = value;
        }
      });
    }

    return Playlist(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      cifraIds: List<int>.from(json['cifra_ids'] ?? []),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      remoteCode: json['remote_code'] as String?,
      visibility: json['visibility'] == 'church' ? 'church' : 'private',
      serviceDate: json['service_date'] as String?,
      cifraNotes: notes,
      pendingSync: json['pending_sync'] == true,
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
      'remote_code': remoteCode,
      'visibility': visibility,
      'service_date': serviceDate,
      'cifra_notes': cifraNotes.map((k, v) => MapEntry(k.toString(), v)),
      'pending_sync': pendingSync,
    };
  }

  /// Formato esperado pela API (POST/PUT /playlist).
  Map<String, dynamic> toRemotePayload() {
    return {
      'title': title,
      'description': description,
      'service_date': serviceDate,
      'visibility': visibility,
      'items': cifraIds
          .map((id) => {'music_id': id, 'note': cifraNotes[id]})
          .toList(),
    };
  }

  Playlist copyWith({
    String? id,
    String? title,
    String? description,
    List<int>? cifraIds,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? remoteCode,
    bool clearRemoteCode = false,
    String? visibility,
    String? serviceDate,
    bool clearServiceDate = false,
    Map<int, String>? cifraNotes,
    bool? pendingSync,
  }) {
    return Playlist(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      cifraIds: cifraIds ?? this.cifraIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      remoteCode: clearRemoteCode ? null : (remoteCode ?? this.remoteCode),
      visibility: visibility ?? this.visibility,
      serviceDate: clearServiceDate ? null : (serviceDate ?? this.serviceDate),
      cifraNotes: cifraNotes ?? this.cifraNotes,
      pendingSync: pendingSync ?? this.pendingSync,
    );
  }

  // Método para gerar um ID único baseado em timestamp
  static String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}
