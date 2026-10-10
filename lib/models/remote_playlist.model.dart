import 'playlist.model.dart';

class RemotePlaylistItem {
  final int musicId;
  final int position;
  final String? note;

  const RemotePlaylistItem({
    required this.musicId,
    required this.position,
    this.note,
  });

  factory RemotePlaylistItem.fromJson(Map<String, dynamic> json) {
    return RemotePlaylistItem(
      musicId: (json['music_id'] as num).toInt(),
      position: (json['position'] as num?)?.toInt() ?? 0,
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'music_id': musicId,
    'position': position,
    'note': note,
  };
}

/// Playlist como vem da API (de qualquer pessoa da igreja).
class RemotePlaylist {
  final String code;
  final String title;
  final String description;
  final String? serviceDate;
  final String visibility;
  final String? ownerName;
  final bool isMine;
  final List<RemotePlaylistItem> items;
  final DateTime updatedAt;

  const RemotePlaylist({
    required this.code,
    required this.title,
    required this.description,
    required this.serviceDate,
    required this.visibility,
    required this.ownerName,
    required this.isMine,
    required this.items,
    required this.updatedAt,
  });

  DateTime? get serviceDateValue =>
      serviceDate == null ? null : DateTime.tryParse(serviceDate!);

  List<int> get musicIds => items.map((i) => i.musicId).toList();

  factory RemotePlaylist.fromJson(Map<String, dynamic> json) {
    final items =
        (json['items'] as List? ?? [])
            .map(
              (e) => RemotePlaylistItem.fromJson(Map<String, dynamic>.from(e)),
            )
            .toList()
          ..sort((a, b) => a.position.compareTo(b.position));

    return RemotePlaylist(
      code: json['code'] as String,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      serviceDate: _dateOnly(json['service_date']),
      visibility: json['visibility'] == 'church' ? 'church' : 'private',
      ownerName: json['owner_name'] as String?,
      isMine: json['is_mine'] == true,
      items: items,
      updatedAt:
          DateTime.tryParse(json['updated_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'code': code,
    'title': title,
    'description': description,
    'service_date': serviceDate,
    'visibility': visibility,
    'owner_name': ownerName,
    'is_mine': isMine,
    'items': items.map((i) => i.toJson()).toList(),
    'updated_at': updatedAt.toIso8601String(),
  };

  static String? _dateOnly(dynamic value) {
    final text = value?.toString();
    if (text == null || text.isEmpty) return null;
    return text.length >= 10 ? text.substring(0, 10) : text;
  }

  /// Cópia local editável ("Salvar uma cópia").
  Playlist toLocalCopy() {
    final now = DateTime.now();
    final notes = <int, String>{};
    for (final item in items) {
      if (item.note != null && item.note!.isNotEmpty) {
        notes[item.musicId] = item.note!;
      }
    }
    return Playlist(
      id: Playlist.generateId(),
      title: title,
      description: description,
      cifraIds: musicIds,
      createdAt: now,
      updatedAt: now,
      serviceDate: serviceDate,
      cifraNotes: notes,
    );
  }
}

class ChurchPlaylists {
  final List<RemotePlaylist> upcoming;
  final List<RemotePlaylist> past;
  final int pastTotal;

  /// true quando veio do cache local (sem internet)
  final bool fromCache;

  const ChurchPlaylists({
    required this.upcoming,
    required this.past,
    required this.pastTotal,
    this.fromCache = false,
  });

  bool get isEmpty => upcoming.isEmpty && past.isEmpty;
}
