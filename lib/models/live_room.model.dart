/// Dados mínimos da cifra que vêm junto no estado da sala (para mostrar
/// na hora quem ainda não tem a cifra no aparelho).
class LiveMusicInfo {
  final int id;
  final String title;
  final String kind;
  final String? fileUrl;

  const LiveMusicInfo({
    required this.id,
    required this.title,
    required this.kind,
    this.fileUrl,
  });

  static LiveMusicInfo? fromJson(dynamic json) {
    if (json is! Map) return null;
    final id = (json['id'] as num?)?.toInt();
    if (id == null) return null;
    return LiveMusicInfo(
      id: id,
      title: json['title'] as String? ?? 'Cifra',
      kind: json['kind'] as String? ?? 'pdf',
      fileUrl: json['file_url'] as String?,
    );
  }
}

class LiveCurrent {
  final int musicId;
  final String? note;
  final DateTime setAt;
  final String? setByName;
  final LiveMusicInfo? music;

  const LiveCurrent({
    required this.musicId,
    this.note,
    required this.setAt,
    this.setByName,
    this.music,
  });

  factory LiveCurrent.fromJson(Map<String, dynamic> json) => LiveCurrent(
    musicId: (json['music_id'] as num).toInt(),
    note: json['note'] as String?,
    setAt: DateTime.tryParse(json['set_at']?.toString() ?? '') ?? DateTime.now(),
    setByName: json['set_by_name'] as String?,
    music: LiveMusicInfo.fromJson(json['music']),
  );
}

class LiveHistoryItem {
  final int musicId;
  final LiveMusicInfo? music;
  final String? note;
  final DateTime playedAt;
  final String? playedByName;

  const LiveHistoryItem({
    required this.musicId,
    this.music,
    this.note,
    required this.playedAt,
    this.playedByName,
  });

  factory LiveHistoryItem.fromJson(Map<String, dynamic> json) =>
      LiveHistoryItem(
        musicId: (json['music_id'] as num).toInt(),
        music: LiveMusicInfo.fromJson(json['music']),
        note: json['note'] as String?,
        playedAt:
            DateTime.tryParse(json['played_at']?.toString() ?? '')?.toLocal() ??
            DateTime.now(),
        playedByName: json['played_by_name'] as String?,
      );
}

class LiveQueueItem {
  final String id;
  final int musicId;
  final String? note;
  final String? addedByName;
  final bool addedByMe;
  final LiveMusicInfo? music;

  const LiveQueueItem({
    required this.id,
    required this.musicId,
    this.note,
    this.addedByName,
    required this.addedByMe,
    this.music,
  });

  factory LiveQueueItem.fromJson(Map<String, dynamic> json) => LiveQueueItem(
    id: json['id'] as String,
    musicId: (json['music_id'] as num).toInt(),
    note: json['note'] as String?,
    addedByName: json['added_by_name'] as String?,
    addedByMe: json['added_by_me'] == true,
    music: LiveMusicInfo.fromJson(json['music']),
  );
}

class LiveParticipant {
  final String id;
  final String? name;
  final int? viewingMusicId;
  final bool following;
  final bool isLeader;
  final bool isMe;

  const LiveParticipant({
    required this.id,
    this.name,
    this.viewingMusicId,
    required this.following,
    required this.isLeader,
    required this.isMe,
  });

  String get displayName =>
      (name == null || name!.isEmpty) ? 'Sem nome' : name!;

  factory LiveParticipant.fromJson(Map<String, dynamic> json) =>
      LiveParticipant(
        id: json['id'] as String,
        name: json['name'] as String?,
        viewingMusicId: (json['viewing_music_id'] as num?)?.toInt(),
        following: json['following'] != false,
        isLeader: json['is_leader'] == true,
        isMe: json['is_me'] == true,
      );
}

class LiveChatMessage {
  final int id;
  final String authorId;
  final String? authorName;
  final bool isMe;
  final String text;
  final int? musicId;
  final LiveMusicInfo? music;
  final DateTime createdAt;

  const LiveChatMessage({
    required this.id,
    required this.authorId,
    this.authorName,
    required this.isMe,
    required this.text,
    this.musicId,
    this.music,
    required this.createdAt,
  });

  String get displayName =>
      (authorName == null || authorName!.isEmpty) ? 'Sem nome' : authorName!;

  factory LiveChatMessage.fromJson(Map<String, dynamic> json) =>
      LiveChatMessage(
        id: (json['id'] as num).toInt(),
        authorId: json['author_id'] as String? ?? '',
        authorName: json['author_name'] as String?,
        isMe: json['is_me'] == true,
        text: json['text'] as String? ?? '',
        musicId: (json['music_id'] as num?)?.toInt(),
        music: LiveMusicInfo.fromJson(json['music']),
        createdAt:
            DateTime.tryParse(json['created_at']?.toString() ?? '')?.toLocal() ??
            DateTime.now(),
      );
}

class LiveRoomState {
  final String code;
  final String title;
  final String? playlistCode;
  final String? leaderName;
  final bool isLeader;
  final bool leaderAway;
  final LiveCurrent? current;
  final List<LiveQueueItem> queue;
  final List<LiveParticipant> participants;
  final int version;

  /// O que já tocou nesta sala, mais recente primeiro.
  final List<LiveHistoryItem> history;

  /// Mensagens novas desde o último sync (ou as últimas 50 na entrada).
  final List<LiveChatMessage> messages;
  final int lastMessageId;

  const LiveRoomState({
    required this.code,
    required this.title,
    this.playlistCode,
    this.leaderName,
    required this.isLeader,
    required this.leaderAway,
    this.current,
    required this.queue,
    required this.participants,
    required this.version,
    this.history = const [],
    this.messages = const [],
    this.lastMessageId = 0,
  });

  factory LiveRoomState.fromJson(Map<String, dynamic> json) {
    List<T> list<T>(String key, T Function(Map<String, dynamic>) f) =>
        (json[key] as List? ?? [])
            .map((e) => f(Map<String, dynamic>.from(e)))
            .toList();

    return LiveRoomState(
      code: json['code'] as String,
      title: json['title'] as String? ?? 'Sala ao vivo',
      playlistCode: json['playlist_code'] as String?,
      leaderName: json['leader_name'] as String?,
      isLeader: json['is_leader'] == true,
      leaderAway: json['leader_away'] == true,
      current: json['current'] == null
          ? null
          : LiveCurrent.fromJson(Map<String, dynamic>.from(json['current'])),
      queue: list('queue', LiveQueueItem.fromJson),
      participants: list('participants', LiveParticipant.fromJson),
      version: (json['version'] as num?)?.toInt() ?? 0,
      history: list('history', LiveHistoryItem.fromJson),
      messages: list('messages', LiveChatMessage.fromJson),
      lastMessageId: (json['last_message_id'] as num?)?.toInt() ?? 0,
    );
  }
}

class LiveRoomSummary {
  final String code;
  final String title;
  final String? leaderName;
  final int participantsCount;
  final int? currentMusicId;

  const LiveRoomSummary({
    required this.code,
    required this.title,
    this.leaderName,
    required this.participantsCount,
    this.currentMusicId,
  });

  factory LiveRoomSummary.fromJson(Map<String, dynamic> json) =>
      LiveRoomSummary(
        code: json['code'] as String,
        title: json['title'] as String? ?? 'Sala ao vivo',
        leaderName: json['leader_name'] as String?,
        participantsCount: (json['participants_count'] as num?)?.toInt() ?? 0,
        currentMusicId: (json['current_music_id'] as num?)?.toInt(),
      );
}
