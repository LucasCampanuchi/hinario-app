import 'dart:async';

import 'package:flutter/material.dart';

import '../../api/connection/app_api.dart';
import '../../models/live_room.model.dart';
import '../../models/playlist.model.dart';
import '../../services/cifra_lookup_service.dart';
import '../../services/client_identity_service.dart';
import '../../services/live_room_service.dart';
import '../../utils/cifra_title.dart';
import 'live_room_page.dart';

const _primary = Color(0xFF3E5A86);
const _live = Color(0xFFE53935);

/// Cria uma sala e já abre a tela dela.
///
/// - [playlistCode]: playlist que já existe na API (a fila vem dela).
/// - [localPlaylist]: playlist só local; os itens são colocados na fila.
Future<void> startLiveRoom(
  BuildContext context, {
  String? title,
  String? playlistCode,
  Playlist? localPlaylist,
}) async {
  final identity = ClientIdentityService.instance;
  if (!await identity.ensureName(context)) return;
  if (!context.mounted) return;

  final service = LiveRoomService.instance;
  _showLoading(context);
  try {
    final code = playlistCode ?? localPlaylist?.remoteCode;
    var state = await service.create(
      title: title ?? localPlaylist?.title,
      playlistCode: code,
    );

    // Playlist que nunca foi para a API: coloca as cifras na fila uma a uma
    if (code == null && localPlaylist != null) {
      for (final id in localPlaylist.cifraIds) {
        state = await service.addToQueue(
          state.code,
          id,
          note: localPlaylist.cifraNotes[id],
        );
      }
    }

    if (!context.mounted) return;
    Navigator.of(context).pop(); // loading
    await _openRoom(context, state);
  } on ApiException catch (e) {
    if (!context.mounted) return;
    Navigator.of(context).pop();
    _error(context, e.message);
  }
}

Future<void> joinLiveRoom(BuildContext context, String code) async {
  final identity = ClientIdentityService.instance;
  if (!await identity.ensureName(context)) return;
  if (!context.mounted) return;

  _showLoading(context);
  try {
    final state = await LiveRoomService.instance.get(code);
    if (!context.mounted) return;
    Navigator.of(context).pop();
    await _openRoom(context, state);
  } on ApiException catch (e) {
    if (!context.mounted) return;
    Navigator.of(context).pop();
    _error(
      context,
      e.isNotFound ? 'Sala não encontrada ou já encerrada.' : e.message,
    );
  }
}

Future<void> _openRoom(BuildContext context, LiveRoomState state) {
  return Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => LiveRoomPage(initialState: state)),
  );
}

void _showLoading(BuildContext context) {
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(child: CircularProgressIndicator()),
  );
}

void _error(BuildContext context, String message) {
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
}

Future<String?> askLiveRoomCode(BuildContext context) {
  final controller = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Entrar numa sala'),
      content: TextField(
        controller: controller,
        autofocus: true,
        textCapitalization: TextCapitalization.characters,
        maxLength: 5,
        decoration: const InputDecoration(
          labelText: 'Código da sala',
          hintText: 'Ex.: K7P2Q',
        ),
        onSubmitted: (v) => Navigator.of(dialogContext).pop(v),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(controller.text),
          child: const Text('Entrar'),
        ),
      ],
    ),
  );
}

/// Aba "Ao vivo": salas abertas agora + criar/entrar.
class LiveRoomsTab extends StatefulWidget {
  const LiveRoomsTab({super.key});

  @override
  State<LiveRoomsTab> createState() => _LiveRoomsTabState();
}

class _LiveRoomsTabState extends State<LiveRoomsTab> {
  List<LiveRoomSummary>? _rooms;
  Map<int, String> _titles = {};
  String? _error;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _load();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) => _load());
    CifraLookupService.instance.all().then((map) {
      if (mounted) {
        setState(() => _titles = map.map((k, v) => MapEntry(k, CifraTitle.parse(v.title).name)));
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final rooms = await LiveRoomService.instance.listActive();
      if (mounted) {
        setState(() {
          _rooms = rooms;
          _error = null;
        });
      }
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          Card(
            elevation: 0,
            color: _primary.withValues(alpha: 0.06),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Tocar junto, ao vivo',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Quem conduz escolhe a cifra e ela abre sozinha no celular de todo mundo que está na sala.',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(backgroundColor: _live),
                    onPressed: () async {
                      await startLiveRoom(context, title: 'Sala ao vivo');
                      _load();
                    },
                    icon: const Icon(Icons.sensors_rounded),
                    label: const Text('Criar sala agora'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final code = await askLiveRoomCode(context);
                      if (code != null && code.trim().isNotEmpty && mounted) {
                        await joinLiveRoom(context, code);
                        _load();
                      }
                    },
                    icon: const Icon(Icons.login_rounded),
                    label: const Text('Entrar com código'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'ABERTAS AGORA',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          if (_rooms == null && _error == null)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_error != null && (_rooms == null || _rooms!.isEmpty))
            Text(_error!, style: const TextStyle(color: Colors.red))
          else if (_rooms!.isEmpty)
            Text(
              'Nenhuma sala aberta. Crie uma, ou toque "Tocar ao vivo" numa playlist.',
              style: TextStyle(color: Colors.grey.shade600),
            )
          else
            ..._rooms!.map(
              (room) => Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(color: _live.withValues(alpha: 0.3)),
                ),
                child: ListTile(
                  leading: const Icon(Icons.sensors_rounded, color: _live),
                  title: Text(
                    room.title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    [
                      if (room.leaderName != null) room.leaderName!,
                      '${room.participantsCount} na sala',
                      if (room.currentMusicId != null)
                        'tocando ${_titles[room.currentMusicId] ?? 'nº ${room.currentMusicId}'}',
                    ].join(' · '),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    await joinLiveRoom(context, room.code);
                    _load();
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
