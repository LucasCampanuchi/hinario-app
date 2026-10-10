import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../api/connection/app_api.dart';
import '../../models/live_room.model.dart';
import '../../services/live_room_service.dart';

/// Mantém a sala sincronizada enquanto a tela está aberta.
///
/// Usa polling (a cada 2s com o app em primeiro plano). Toda resposta traz
/// o estado completo, então reconectar depois de a tela apagar é só
/// continuar sincronizando — não há mensagem perdida.
class LiveRoomController extends ChangeNotifier with WidgetsBindingObserver {
  LiveRoomController({required this.code, LiveRoomState? initial})
    : _state = initial {
    if (initial != null) _mergeMessages(initial, notifyNew: false);
  }

  static const Duration _interval = Duration(seconds: 2);
  static const Duration _intervalWithError = Duration(seconds: 5);

  final String code;
  final LiveRoomService _service = LiveRoomService.instance;

  LiveRoomState? _state;
  LiveRoomState? get state => _state;

  /// Se true, a cifra na tela troca sozinha quando quem conduz troca.
  bool _following = true;
  bool get following => _following;

  /// Cifra que eu estou vendo (pode ser diferente da atual se eu me soltei).
  int? _viewingMusicId;
  int? get viewingMusicId => _viewingMusicId;

  bool _connectionIssue = false;
  bool get connectionIssue => _connectionIssue;

  bool _closed = false;
  bool get closed => _closed;

  String? _lastError;
  String? get lastError => _lastError;

  // ---- Chat (efêmero, só enquanto a sala existe) ----------------------------
  final List<LiveChatMessage> _messages = [];
  List<LiveChatMessage> get messages => List.unmodifiable(_messages);
  int _lastMessageId = 0;

  int _unread = 0;
  int get unread => _unread;

  bool _chatOpen = false;

  /// Última mensagem recebida para o aviso por cima da cifra (some sozinha).
  final ValueNotifier<LiveChatMessage?> banner = ValueNotifier(null);
  Timer? _bannerTimer;

  Timer? _timer;
  bool _syncing = false;
  bool _disposed = false;
  bool _paused = false;

  void start() {
    WidgetsBinding.instance.addObserver(this);
    _syncNow();
  }

  // ---------------------------------------------------------------------------

  void setFollowing(bool value) {
    _following = value;
    if (value) _viewingMusicId = _state?.current?.musicId;
    _notify();
    _syncNow();
  }

  /// Chamado pela tela quando a pessoa abre outra cifra por conta própria.
  void setViewing(int? musicId) {
    _viewingMusicId = musicId;
    if (_following && musicId != _state?.current?.musicId) {
      _following = false;
    }
    _notify();
  }

  Future<void> playNow({int? musicId, String? queueItemId}) => _act(
    () => _service.setCurrent(code, musicId: musicId, queueItemId: queueItemId),
    afterSuccess: () {
      // quem conduz sempre acompanha o que escolheu
      _following = true;
      _viewingMusicId = _state?.current?.musicId;
    },
  );

  Future<void> clearCurrent() => _act(() => _service.clearCurrent(code));

  Future<void> sendMessage(String text, {int? musicId}) => _act(
    () => _service.sendMessage(
      code,
      text: text,
      musicId: musicId,
      afterMessageId: _lastMessageId,
    ),
  );

  /// Chat aberto: zera não lidas e não mostra aviso por cima.
  void setChatOpen(bool open) {
    _chatOpen = open;
    if (open) {
      _unread = 0;
      dismissBanner();
    }
    _notify();
  }

  /// O que a sala sabe sobre uma cifra (título, tipo, URL do arquivo).
  LiveMusicInfo? infoFor(int musicId) {
    final s = _state;
    if (s?.current?.musicId == musicId && s?.current?.music != null) {
      return s!.current!.music;
    }
    for (final q in s?.queue ?? const <LiveQueueItem>[]) {
      if (q.musicId == musicId && q.music != null) return q.music;
    }
    for (final m in _messages.reversed) {
      if (m.musicId == musicId && m.music != null) return m.music;
    }
    for (final h in s?.history ?? const <LiveHistoryItem>[]) {
      if (h.musicId == musicId && h.music != null) return h.music;
    }
    return null;
  }

  void dismissBanner() {
    _bannerTimer?.cancel();
    banner.value = null;
  }

  Future<void> addToQueue(int musicId) =>
      _act(() => _service.addToQueue(code, musicId));

  Future<void> removeFromQueue(String itemId) =>
      _act(() => _service.removeFromQueue(code, itemId));

  Future<void> reorderQueue(List<String> ids) =>
      _act(() => _service.reorderQueue(code, ids));

  Future<void> passLeadership(String participantId) =>
      _act(() => _service.changeLeader(code, participantId: participantId));

  Future<void> takeLeadership() => _act(() => _service.changeLeader(code));

  Future<void> closeRoom() async {
    await _service.close(code);
    _closed = true;
    _stop();
    _notify();
  }

  Future<void> leave() async {
    _stop();
    try {
      await _service.leave(code);
    } catch (_) {
      // a presença expira sozinha em 20s
    }
  }

  // ---------------------------------------------------------------------------

  Future<void> _act(
    Future<LiveRoomState> Function() call, {
    VoidCallback? afterSuccess,
  }) async {
    try {
      final result = await call();
      _applyState(result);
      afterSuccess?.call();
      _lastError = null;
      _notify();
    } on ApiException catch (e) {
      _lastError = e.message;
      if (e.isNotFound) _markClosed();
      _notify();
      rethrow;
    }
  }

  Future<void> _syncNow() async {
    if (_syncing || _closed || _disposed) return;
    _syncing = true;
    _timer?.cancel();

    try {
      final result = await _service.sync(
        code,
        viewingMusicId: _viewingMusicId,
        following: _following,
        afterMessageId: _lastMessageId,
      );
      _applyState(result);
      _connectionIssue = false;
    } on ApiException catch (e) {
      if (e.isNotFound) {
        _markClosed();
      } else {
        _connectionIssue = true;
      }
    } finally {
      _syncing = false;
      _notify();
      if (!_closed && !_disposed && !_paused) {
        _timer = Timer(
          _connectionIssue ? _intervalWithError : _interval,
          _syncNow,
        );
      }
    }
  }

  void _applyState(LiveRoomState next) {
    final previousCurrent = _state?.current?.musicId;
    _state = next;
    _mergeMessages(next);
    final newCurrent = next.current?.musicId;

    if (_following && newCurrent != previousCurrent) {
      _viewingMusicId = newCurrent;
    }
    if (_following && _viewingMusicId == null && newCurrent != null) {
      _viewingMusicId = newCurrent;
    }
  }

  void _mergeMessages(LiveRoomState next, {bool notifyNew = true}) {
    final fresh = next.messages.where((m) => m.id > _lastMessageId).toList()
      ..sort((a, b) => a.id.compareTo(b.id));
    if (fresh.isEmpty) return;
    _messages.addAll(fresh);
    if (_messages.length > 200) {
      _messages.removeRange(0, _messages.length - 200);
    }
    _lastMessageId = fresh.last.id;

    if (!notifyNew || _chatOpen) return;
    final incoming = fresh.where((m) => !m.isMe).toList();
    if (incoming.isEmpty) return;
    _unread += incoming.length;
    banner.value = incoming.last;
    _bannerTimer?.cancel();
    _bannerTimer = Timer(const Duration(seconds: 6), () {
      if (!_disposed) banner.value = null;
    });
  }

  void _markClosed() {
    _closed = true;
    _stop();
  }

  void _stop() {
    _timer?.cancel();
    _timer = null;
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycle) {
    if (lifecycle == AppLifecycleState.resumed) {
      _paused = false;
      _syncNow(); // voltou da tela apagada: pega o estado na hora
    } else if (lifecycle == AppLifecycleState.paused) {
      _paused = true;
      _stop();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _stop();
    _bannerTimer?.cancel();
    banner.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
