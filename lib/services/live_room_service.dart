import '../api/connection/app_api.dart';
import '../models/live_room.model.dart';
import 'client_identity_service.dart';

/// Rotas /live-room da API.
class LiveRoomService {
  LiveRoomService._();
  static final LiveRoomService instance = LiveRoomService._();

  final ClientIdentityService _identity = ClientIdentityService.instance;

  LiveRoomState _parse(dynamic data) =>
      LiveRoomState.fromJson(Map<String, dynamic>.from(data));

  Future<List<LiveRoomSummary>> listActive() async {
    final data = await AppApi.get('live-room/active');
    return (data as List)
        .map((e) => LiveRoomSummary.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<LiveRoomState> create({String? title, String? playlistCode}) async {
    final data = await AppApi.post(
      'live-room',
      data: {
        ...await _identity.actorPayload(),
        'title': title,
        'playlist_code': playlistCode,
      },
    );
    return _parse(data);
  }

  Future<LiveRoomState> get(String code) async {
    final data = await AppApi.get(
      'live-room/code/${code.trim().toUpperCase()}',
      query: {'client_id': await _identity.getClientId()},
    );
    return _parse(data);
  }

  Future<LiveRoomState> sync(
    String code, {
    int? viewingMusicId,
    required bool following,
    int? afterMessageId,
  }) async {
    final data = await AppApi.post(
      'live-room/$code/sync',
      data: {
        ...await _identity.actorPayload(),
        'viewing_music_id': viewingMusicId,
        'following': following,
        'after_message_id': afterMessageId,
      },
    );
    return _parse(data);
  }

  Future<LiveRoomState> sendMessage(
    String code, {
    required String text,
    int? musicId,
    int? afterMessageId,
  }) async {
    final data = await AppApi.post(
      'live-room/$code/chat',
      data: {
        ...await _identity.actorPayload(),
        'text': text,
        'music_id': musicId,
        'after_message_id': afterMessageId,
      },
    );
    return _parse(data);
  }

  Future<LiveRoomState> setCurrent(
    String code, {
    int? musicId,
    String? queueItemId,
  }) async {
    final data = await AppApi.post(
      'live-room/$code/current',
      data: {
        ...await _identity.actorPayload(),
        'music_id': musicId,
        'queue_item_id': queueItemId,
      },
    );
    return _parse(data);
  }

  Future<LiveRoomState> clearCurrent(String code) async {
    final data = await AppApi.delete(
      'live-room/$code/current',
      data: await _identity.actorPayload(),
    );
    return _parse(data);
  }

  Future<LiveRoomState> addToQueue(
    String code,
    int musicId, {
    String? note,
  }) async {
    final data = await AppApi.post(
      'live-room/$code/queue',
      data: {
        ...await _identity.actorPayload(),
        'music_id': musicId,
        'note': note,
      },
    );
    return _parse(data);
  }

  Future<LiveRoomState> removeFromQueue(String code, String itemId) async {
    final data = await AppApi.delete(
      'live-room/$code/queue/$itemId',
      data: await _identity.actorPayload(),
    );
    return _parse(data);
  }

  Future<LiveRoomState> reorderQueue(String code, List<String> ids) async {
    final data = await AppApi.put(
      'live-room/$code/queue-order',
      data: {...await _identity.actorPayload(), 'ids': ids},
    );
    return _parse(data);
  }

  /// Sem [participantId]: tenta assumir (só funciona se o líder sumiu).
  Future<LiveRoomState> changeLeader(
    String code, {
    String? participantId,
  }) async {
    final data = await AppApi.post(
      'live-room/$code/leader',
      data: {
        ...await _identity.actorPayload(),
        'participant_id': participantId,
      },
    );
    return _parse(data);
  }

  Future<void> leave(String code) async {
    await AppApi.post(
      'live-room/$code/leave',
      data: await _identity.actorPayload(),
    );
  }

  Future<void> close(String code) async {
    await AppApi.delete('live-room/$code', data: await _identity.actorPayload());
  }
}
