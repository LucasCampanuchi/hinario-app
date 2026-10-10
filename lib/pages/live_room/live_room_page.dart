import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../api/connection/app_api.dart';
import '../../models/cifra.dart';
import '../../models/live_room.model.dart';
import '../../models/playlist.model.dart';
import '../../services/playlist.service.dart';
import '../../services/cifra_download_service.dart';
import '../../services/cifra_lookup_service.dart';
import '../../utils/cifra_title.dart';
import '../cifras/pages/cifra_view_page/view/cifra_view_page.dart';
import 'live_room_controller.dart';
import '../cifras/pages/new_cifra/new_cifra_flow.dart';
import 'widgets/cifra_picker_sheet.dart';
import 'widgets/live_chat.dart';

const _primary = Color(0xFF3E5A86);
const _live = Color(0xFFE53935);

/// Tela da sala ao vivo.
///
/// - Com uma cifra para mostrar: o PDF ocupa a tela e embaixo fica a barra
///   da sala (quem conduz, seguir/soltar, fila).
/// - Sem cifra ainda: mostra o painel da sala (fila, pessoas, ações).
class LiveRoomPage extends StatefulWidget {
  final LiveRoomState initialState;

  const LiveRoomPage({super.key, required this.initialState});

  @override
  State<LiveRoomPage> createState() => _LiveRoomPageState();
}

class _LiveRoomPageState extends State<LiveRoomPage> {
  late final LiveRoomController _controller;
  Map<int, Cifra> _cifras = {};
  bool _closedDialogShown = false;

  /// Cifras que estão sendo baixadas agora (ex.: foto que alguém mandou)
  final Set<int> _downloading = {};
  final Set<int> _downloadFailed = {};
  final Map<int, DateTime> _failedAt = {};

  /// Dados de cifras buscados na API quando a sala não mandou (API antiga).
  final Map<int, LiveMusicInfo> _fetchedInfo = {};
  final Set<int> _fetchingInfo = {};

  /// URL/título/tipo da cifra: primeiro o que veio na sala, senão busca na API.
  LiveMusicInfo? _resolveInfo(int musicId) {
    final info = _controller.infoFor(musicId) ?? _fetchedInfo[musicId];
    if (info?.fileUrl != null) return info;
    if (_fetchingInfo.add(musicId)) {
      AppApi.get('music-external/$musicId')
          .then((data) {
            final cifra = Cifra.fromJson(Map<String, dynamic>.from(data));
            final url = cifra.file?.url;
            if (url == null) return;
            _fetchedInfo[musicId] = LiveMusicInfo(
              id: musicId,
              title: cifra.title,
              kind: cifra.kind,
              fileUrl: url,
            );
            if (mounted) setState(() {});
          })
          .catchError((_) {})
          .whenComplete(() => _fetchingInfo.remove(musicId));
    }
    return info;
  }

  @override
  void initState() {
    super.initState();
    _controller = LiveRoomController(
      code: widget.initialState.code,
      initial: widget.initialState,
    );
    _controller.addListener(_onControllerChanged);
    _controller.start();
    CifraLookupService.instance.all(refresh: true).then((map) {
      if (mounted) setState(() => _cifras = map);
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.leave();
    _controller.dispose();
    super.dispose();
  }

  bool _rebuildScheduled = false;

  void _onControllerChanged() {
    // Redesenha a tela a cada mudança da sala. (Antes só redesenhava quando
    // mudava a cifra vista; aí, se os dados da cifra nova chegavam um
    // instante depois, a tela não atualizava até sair e entrar na sala.)
    // A tela da cifra mantém o PDF/foto aberto: só o que mudou é refeito.
    if (mounted && !_rebuildScheduled) {
      _rebuildScheduled = true;
      scheduleMicrotask(() {
        _rebuildScheduled = false;
        if (mounted) setState(() {});
      });
    }

    if (_controller.closed && !_closedDialogShown && mounted) {
      _closedDialogShown = true;
      final wasLeader = _controller.state?.isLeader ?? false;
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Sala encerrada'),
          content: Text(
            wasLeader
                ? 'Você encerrou a sala.'
                : 'Quem conduzia encerrou esta sala.',
          ),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.of(context).maybePop();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  String _title(int musicId) {
    final cifra = _cifras[musicId];
    final title =
        cifra?.title ??
        _controller.infoFor(musicId)?.title ??
        _fetchedInfo[musicId]?.title;
    if (title == null) return 'Cifra nº $musicId';
    final t = CifraTitle.parse(title);
    return t.hymnRef == null ? t.name : '${t.name} (${t.hymnRef})';
  }

  /// Cifra que não está no aparelho: baixa na hora, sem esperar sincronizar.
  ///
  /// [silent]: a cifra já está aparecendo direto da internet; só guardamos
  /// no aparelho em segundo plano, sem redesenhar a tela.
  void _ensureDownloaded(int musicId, {bool silent = false}) {
    if (_downloading.contains(musicId) || _downloadFailed.contains(musicId)) {
      return;
    }
    _downloading.add(musicId);
    final info = _controller.infoFor(musicId);
    CifraDownloadService.instance
        .ensure(
          musicId,
          title: info?.title,
          kind: info?.kind,
          fileUrl: info?.fileUrl,
        )
        .then((cifra) async {
          final map = await CifraLookupService.instance.all(refresh: true);
          if (!mounted) return;
          _downloading.remove(musicId);
          if (silent) {
            _cifras = map; // na próxima troca de cifra já usa a cópia local
            return;
          }
          setState(() {
            if (cifra == null) {
              _downloadFailed.add(musicId);
              _failedAt[musicId] = DateTime.now();
            }
            _cifras = map;
          });
        })
        .catchError((_) {
          if (!mounted) return;
          setState(() {
            _downloading.remove(musicId);
            _downloadFailed.add(musicId);
            _failedAt[musicId] = DateTime.now();
          });
        });
  }

  void _openChat() {
    showLiveChatSheet(
      context,
      controller: _controller,
      titleOf: _title,
      onOpenCifra: _openFromPanel,
    );
  }

  /// Foto ou cifra digitada na hora, direto para a sala.
  Future<void> _sendNewCifra() async {
    final created = await startNewCifra(context);
    if (created == null || !mounted) return;
    final map = await CifraLookupService.instance.all(refresh: true);
    if (!mounted) return;
    setState(() => _cifras = map);
    await _guard(context, () async {
      if (_controller.state?.isLeader == true) {
        await _controller.playNow(musicId: created.id);
      } else {
        await _controller.addToQueue(created.id);
      }
      await _controller.sendMessage('Mandei esta cifra', musicId: created.id);
    });
  }

  Widget _bar() => _LiveBar(
    controller: _controller,
    titleOf: _title,
    onOpenPanel: _openPanelSheet,
    onOpenChat: _openChat,
  );

  /// Por cima da cifra: aviso do chat + "Agora tocando" (quando me soltei).
  Widget _banner() => Positioned.fill(
    child: Stack(
      children: [
        LiveChatBanner(
          controller: _controller,
          titleOf: _title,
          onOpenChat: _openChat,
        ),
        _nowPlayingPill(),
      ],
    ),
  );

  Widget _nowPlayingPill() {
    final current = _controller.state?.current;
    if (current == null ||
        _controller.following ||
        _controller.viewingMusicId == current.musicId) {
      return const SizedBox.shrink();
    }
    return Positioned(
      left: 12,
      right: 12,
      bottom: 12,
      child: Material(
        elevation: 6,
        color: const Color(0xFFE53935),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _controller.setFollowing(true),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                const Icon(Icons.graphic_eq, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Agora: ${_title(current.musicId)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Text(
                  'IR',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final state = _controller.state!;
        final viewing = _controller.viewingMusicId;

        if (viewing == null) {
          return Scaffold(
            backgroundColor: Colors.grey[50],
            appBar: _panelAppBar(state),
            body: Stack(
              children: [
                Positioned.fill(
                  child: LiveRoomPanel(
                    controller: _controller,
                    titleOf: _title,
                    onOpenCifra: _openFromPanel,
                    onOpenChat: _openChat,
                    onSendNewCifra: _sendNewCifra,
                  ),
                ),
                _banner(),
              ],
            ),
          );
        }

        final cifra = _cifras[viewing];
        final overline = _controller.following
            ? 'AO VIVO · ${state.code}'
            : 'VOCÊ SE SOLTOU · ${state.code}';

        if (cifra == null || cifra.localFilePath == null) {
          // A sala manda a URL junto: mostra NA HORA, direto da internet, e
          // guarda no aparelho em segundo plano.
          final info = _resolveInfo(viewing);
          if (info?.fileUrl != null) {
            WidgetsBinding.instance.addPostFrameCallback(
              (_) => _ensureDownloaded(viewing, silent: true),
            );
            return CifraViewPage(
              key: ValueKey('live-remote-$viewing'),
              cifra: Cifra(
                id: viewing,
                title: info!.title,
                createdAt: '',
                updatedAt: '',
                kind: info.kind,
              ),
              remoteUrl: info.fileUrl,
              overline: overline,
              extraActions: [
                IconButton(
                  tooltip: 'Painel da sala',
                  icon: const Icon(Icons.queue_music_rounded, color: Colors.white),
                  onPressed: _openPanelSheet,
                ),
              ],
              bottomBar: _bar(),
              overlay: _banner(),
            );
          }

          // tenta de novo sozinho a cada 5s se falhou (ex.: internet oscilando)
          final failedAt = _failedAt[viewing];
          if (_downloadFailed.contains(viewing) &&
              failedAt != null &&
              DateTime.now().difference(failedAt).inSeconds >= 5) {
            _downloadFailed.remove(viewing);
          }
          final failed = _downloadFailed.contains(viewing);
          if (!failed) {
            WidgetsBinding.instance.addPostFrameCallback(
              (_) => _ensureDownloaded(viewing),
            );
          }
          return Scaffold(
            appBar: AppBar(
              title: Text(_title(viewing)),
              backgroundColor: _primary,
              foregroundColor: Colors.white,
            ),
            bottomNavigationBar: _bar(),
            body: Stack(
              children: [
                Positioned.fill(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!failed) const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          Text(
                            failed
                                ? 'Não consegui baixar esta cifra agora.'
                                : 'Baixando a cifra...',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16),
                          ),
                          if (failed) ...[
                            const SizedBox(height: 12),
                            OutlinedButton(
                              onPressed: () {
                                setState(() => _downloadFailed.remove(viewing));
                              },
                              child: const Text('Tentar de novo'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                _banner(),
              ],
            ),
          );
        }

        return CifraViewPage(
          key: ValueKey('live-${cifra.id}'),
          cifra: cifra,
          overline: overline,
          extraActions: [
            IconButton(
              tooltip: 'Painel da sala',
              icon: const Icon(Icons.queue_music_rounded, color: Colors.white),
              onPressed: _openPanelSheet,
            ),
          ],
          bottomBar: _bar(),
          overlay: _banner(),
        );
      },
    );
  }

  PreferredSizeWidget _panelAppBar(LiveRoomState state) {
    return AppBar(
      backgroundColor: _primary,
      foregroundColor: Colors.white,
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'AO VIVO',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: Colors.white70,
            ),
          ),
          Text(
            state.title,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
      centerTitle: true,
    );
  }

  void _openFromPanel(int musicId) {
    _controller.setViewing(musicId);
    if (musicId == _controller.state?.current?.musicId) {
      _controller.setFollowing(true);
    }
  }

  void _openPanelSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.grey[50],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        builder: (context, scrollController) => LiveRoomPanel(
          controller: _controller,
          titleOf: _title,
          scrollController: scrollController,
          showHandle: true,
          onOpenCifra: (musicId) {
            Navigator.of(sheetContext).pop();
            _openFromPanel(musicId);
          },
          onAfterPlay: () => Navigator.of(sheetContext).pop(),
          onOpenChat: () {
            Navigator.of(sheetContext).pop();
            _openChat();
          },
          onSendNewCifra: () {
            Navigator.of(sheetContext).pop();
            _sendNewCifra();
          },
          onLeave: () {
            Navigator.of(sheetContext).pop();
            Navigator.of(context).maybePop();
          },
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Barra inferior (sobre o PDF)
// -----------------------------------------------------------------------------

class _LiveBar extends StatelessWidget {
  final LiveRoomController controller;
  final String Function(int) titleOf;
  final VoidCallback onOpenPanel;
  final VoidCallback onOpenChat;

  const _LiveBar({
    required this.controller,
    required this.titleOf,
    required this.onOpenPanel,
    required this.onOpenChat,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) => _build(context),
    );
  }

  Widget _build(BuildContext context) {
    final state = controller.state!;
    final current = state.current;
    final notOnCurrent =
        current != null && controller.viewingMusicId != current.musicId;

    String subtitle;
    if (state.isLeader) {
      subtitle = 'Você conduz · ${state.participants.length} na sala';
    } else {
      subtitle =
          '${state.leaderName ?? 'Alguém'} conduz · ${state.participants.length} na sala';
    }

    return Material(
      color: Colors.white,
      elevation: 8,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
          child: Row(
            children: [
              _StatusDot(
                ok: !controller.connectionIssue,
                following: controller.following,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: InkWell(
                  onTap: onOpenPanel,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        controller.connectionIssue
                            ? 'Reconectando...'
                            : notOnCurrent
                            ? 'Agora: ${titleOf(current!.musicId)}'
                            : current?.note?.isNotEmpty == true
                            ? current!.note!
                            : subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        state.queue.isEmpty
                            ? subtitle
                            : 'Próxima: ${titleOf(state.queue.first.musicId)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (notOnCurrent)
                TextButton(
                  onPressed: () => controller.setFollowing(true),
                  child: const Text('Voltar'),
                )
              else if (state.isLeader && state.queue.isNotEmpty)
                FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: _primary),
                  onPressed: () => _guard(
                    context,
                    () => controller.playNow(
                      queueItemId: state.queue.first.id,
                    ),
                  ),
                  icon: const Icon(Icons.skip_next_rounded, size: 18),
                  label: const Text('Próxima'),
                ),
              IconButton(
                tooltip: 'Conversa',
                onPressed: onOpenChat,
                icon: Badge(
                  isLabelVisible: controller.unread > 0,
                  label: Text('${controller.unread}'),
                  child: const Icon(Icons.forum_outlined),
                ),
              ),
              IconButton(
                tooltip: 'Fila e pessoas',
                onPressed: onOpenPanel,
                icon: Badge(
                  isLabelVisible: state.queue.isNotEmpty,
                  label: Text('${state.queue.length}'),
                  child: const Icon(Icons.queue_music_rounded),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  final bool ok;
  final bool following;

  const _StatusDot({required this.ok, required this.following});

  @override
  Widget build(BuildContext context) {
    final color = !ok
        ? Colors.orange
        : following
        ? _live
        : Colors.grey;
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 6),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Painel da sala (tela cheia ou bottom sheet)
// -----------------------------------------------------------------------------

class LiveRoomPanel extends StatelessWidget {
  final LiveRoomController controller;
  final String Function(int) titleOf;
  final void Function(int musicId) onOpenCifra;
  final VoidCallback? onAfterPlay;
  final VoidCallback? onLeave;
  final VoidCallback? onOpenChat;
  final VoidCallback? onSendNewCifra;
  final ScrollController? scrollController;
  final bool showHandle;

  const LiveRoomPanel({
    super.key,
    required this.controller,
    required this.titleOf,
    required this.onOpenCifra,
    this.onAfterPlay,
    this.onLeave,
    this.onOpenChat,
    this.onSendNewCifra,
    this.scrollController,
    this.showHandle = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final state = controller.state!;
        return ListView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            if (showHandle)
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            _header(context, state),
            const SizedBox(height: 16),
            _currentCard(context, state),
            const SizedBox(height: 16),
            _actions(context, state),
            const SizedBox(height: 24),
            _sectionTitle(
              'Fila',
              state.queue.isEmpty ? null : '${state.queue.length}',
            ),
            if (state.queue.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  state.isLeader
                      ? 'Fila vazia. Use "Escolher cifra" ou deixe os outros sugerirem.'
                      : 'Fila vazia. Você pode sugerir uma cifra.',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              )
            else
              ...state.queue.asMap().entries.map(
                (e) => _queueTile(context, state, e.key, e.value),
              ),
            if (state.history.isNotEmpty) ...[
              const SizedBox(height: 24),
              _historySection(context, state),
            ],
            const SizedBox(height: 24),
            _sectionTitle('Na sala', '${state.participants.length}'),
            ...state.participants.map((p) => _participantTile(context, state, p)),
            const SizedBox(height: 24),
            if (state.isLeader)
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                ),
                onPressed: () => _confirmClose(context),
                icon: const Icon(Icons.stop_circle_outlined),
                label: const Text('Encerrar sala para todos'),
              )
            else
              OutlinedButton.icon(
                onPressed: onLeave ?? () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.logout),
                label: const Text('Sair da sala'),
              ),
          ],
        );
      },
    );
  }

  Widget _header(BuildContext context, LiveRoomState state) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                state.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                state.isLeader
                    ? 'Você está conduzindo'
                    : 'Conduzindo: ${state.leaderName ?? 'sem nome'}',
                style: TextStyle(color: Colors.grey.shade700),
              ),
              if (controller.connectionIssue)
                const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text(
                    'Sem conexão — tentando de novo...',
                    style: TextStyle(color: Colors.orange, fontSize: 12),
                  ),
                ),
            ],
          ),
        ),
        InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => _shareCode(context, state),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Text(
                  state.code,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                    color: _primary,
                  ),
                ),
                const Text(
                  'código',
                  style: TextStyle(fontSize: 10, color: _primary),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _currentCard(BuildContext context, LiveRoomState state) {
    final current = state.current;
    return Card(
      elevation: 0,
      color: current == null ? Colors.white : _live.withValues(alpha: 0.06),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: current == null
              ? Colors.grey.shade200
              : _live.withValues(alpha: 0.4),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(
          current == null ? Icons.hourglass_empty_rounded : Icons.graphic_eq,
          color: current == null ? Colors.grey : _live,
        ),
        title: Text(
          current == null ? 'Aguardando a primeira cifra' : titleOf(current.musicId),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          current == null
              ? (state.isLeader
                    ? 'Escolha uma cifra ou toque em um item da fila.'
                    : 'Quando quem conduz escolher, ela abre sozinha aqui.')
              : [
                  'Tocando agora',
                  if (current.note?.isNotEmpty == true) current.note!,
                ].join(' · '),
        ),
        trailing: current == null
            ? null
            : TextButton(
                onPressed: () => onOpenCifra(current.musicId),
                child: const Text('Abrir'),
              ),
      ),
    );
  }

  Widget _actions(BuildContext context, LiveRoomState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            if (state.isLeader)
              Expanded(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: _primary,
                    minimumSize: const Size.fromHeight(46),
                  ),
                  onPressed: () => _pickAndPlay(context),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Escolher cifra'),
                ),
              ),
            if (state.isLeader) const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(46),
                ),
                onPressed: () => _pickAndQueue(context, state),
                icon: const Icon(Icons.playlist_add_rounded),
                label: Text(state.isLeader ? 'Pôr na fila' : 'Sugerir cifra'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(46),
                ),
                onPressed: onOpenChat,
                icon: Badge(
                  isLabelVisible: controller.unread > 0,
                  label: Text('${controller.unread}'),
                  child: const Icon(Icons.forum_outlined),
                ),
                label: const Text('Conversa'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(46),
                ),
                onPressed: onSendNewCifra,
                icon: const Icon(Icons.add_a_photo_outlined),
                label: const Text('Foto / nova cifra'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: controller.following,
          onChanged: controller.setFollowing,
          title: const Text('Seguir quem conduz'),
          subtitle: const Text('A cifra troca sozinha na sua tela'),
        ),
        if (!state.isLeader && state.leaderAway)
          Card(
            color: Colors.orange.shade50,
            elevation: 0,
            child: ListTile(
              leading: const Icon(Icons.warning_amber_rounded, color: Colors.orange),
              title: const Text('Quem conduzia saiu da sala'),
              trailing: TextButton(
                onPressed: () => _guard(context, controller.takeLeadership),
                child: const Text('Assumir'),
              ),
            ),
          ),
      ],
    );
  }

  Widget _sectionTitle(String text, String? count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(
            text.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
              color: Colors.grey.shade700,
            ),
          ),
          if (count != null) ...[
            const SizedBox(width: 6),
            Text(count, style: TextStyle(color: Colors.grey.shade500)),
          ],
        ],
      ),
    );
  }

  Widget _queueTile(
    BuildContext context,
    LiveRoomState state,
    int index,
    LiveQueueItem item,
  ) {
    final canRemove = state.isLeader || item.addedByMe;
    final subtitle = [
      if (item.addedByName != null) 'por ${item.addedByName}',
      if (item.note?.isNotEmpty == true) item.note!,
    ].join(' · ');

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: CircleAvatar(
          radius: 14,
          backgroundColor: _primary.withValues(alpha: 0.12),
          child: Text(
            '${index + 1}',
            style: const TextStyle(fontSize: 12, color: _primary),
          ),
        ),
        title: Text(titleOf(item.musicId)),
        subtitle: subtitle.isEmpty ? null : Text(subtitle),
        onTap: state.isLeader
            ? () => _guard(context, () async {
                await controller.playNow(queueItemId: item.id);
                onAfterPlay?.call();
              })
            : () => onOpenCifra(item.musicId),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            final ids = state.queue.map((q) => q.id).toList();
            if (value == 'play') {
              _guard(context, () async {
                await controller.playNow(queueItemId: item.id);
                onAfterPlay?.call();
              });
            } else if (value == 'up') {
              ids.removeAt(index);
              ids.insert(index - 1, item.id);
              _guard(context, () => controller.reorderQueue(ids));
            } else if (value == 'top') {
              ids.removeAt(index);
              ids.insert(0, item.id);
              _guard(context, () => controller.reorderQueue(ids));
            } else if (value == 'view') {
              onOpenCifra(item.musicId);
            } else if (value == 'remove') {
              _guard(context, () => controller.removeFromQueue(item.id));
            }
          },
          itemBuilder: (context) => [
            if (state.isLeader)
              const PopupMenuItem(value: 'play', child: Text('Tocar agora')),
            if (state.isLeader && index > 0)
              const PopupMenuItem(value: 'top', child: Text('Mover para o topo')),
            if (state.isLeader && index > 0)
              const PopupMenuItem(value: 'up', child: Text('Subir uma posição')),
            const PopupMenuItem(value: 'view', child: Text('Ver só para mim')),
            if (canRemove)
              const PopupMenuItem(
                value: 'remove',
                child: Text('Remover', style: TextStyle(color: Colors.red)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _historySection(BuildContext context, LiveRoomState state) {
    String hhmm(DateTime d) =>
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: _sectionTitle('Já tocou', '${state.history.length}')),
            TextButton.icon(
              onPressed: () => _saveHistoryAsPlaylist(context, state),
              icon: const Icon(Icons.playlist_add_check_rounded, size: 18),
              label: const Text('Salvar como playlist'),
            ),
          ],
        ),
        for (final (index, item) in state.history.indexed)
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Text(
              hhmm(item.playedAt),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            title: Text(
              titleOf(item.musicId),
              style: TextStyle(
                fontWeight: index == 0 && state.current?.musicId == item.musicId
                    ? FontWeight.w700
                    : FontWeight.w500,
              ),
            ),
            subtitle: Text(
              [
                if (index == 0 && state.current?.musicId == item.musicId)
                  'tocando agora',
                if (item.note?.isNotEmpty == true) item.note!,
              ].join(' · '),
            ),
            onTap: () => onOpenCifra(item.musicId),
            trailing: state.isLeader
                ? IconButton(
                    tooltip: 'Tocar de novo',
                    icon: const Icon(Icons.replay_rounded),
                    onPressed: () => _guard(context, () async {
                      await controller.playNow(musicId: item.musicId);
                      onAfterPlay?.call();
                    }),
                  )
                : null,
          ),
      ],
    );
  }

  Future<void> _saveHistoryAsPlaylist(
    BuildContext context,
    LiveRoomState state,
  ) async {
    // do mais antigo para o mais novo, sem repetir
    final ids = <int>[];
    for (final item in state.history.reversed) {
      if (!ids.contains(item.musicId)) ids.add(item.musicId);
    }
    final now = DateTime.now();
    final date =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}';
    final playlist = Playlist(
      id: Playlist.generateId(),
      title: '${state.title} – $date',
      description: 'O que tocou na sala ao vivo ${state.code}',
      cifraIds: ids,
      createdAt: now,
      updatedAt: now,
    );
    final ok = await PlaylistService.instance.savePlaylist(playlist);
    if (!context.mounted) return;
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Salvo em Minhas playlists: "${playlist.title}"'
              : 'Não foi possível salvar a playlist',
        ),
      ),
    );
  }

  Widget _participantTile(
    BuildContext context,
    LiveRoomState state,
    LiveParticipant p,
  ) {
    String status;
    if (p.isLeader) {
      status = 'Conduzindo';
    } else if (p.following) {
      status = 'Seguindo';
    } else if (p.viewingMusicId != null) {
      status = 'Solto · vendo ${titleOf(p.viewingMusicId!)}';
    } else {
      status = 'Solto';
    }
    final behind =
        !p.isLeader &&
        state.current != null &&
        p.viewingMusicId != null &&
        p.viewingMusicId != state.current!.musicId;

    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 16,
        backgroundColor: p.isLeader ? _live : Colors.grey.shade300,
        child: Text(
          p.displayName.characters.first.toUpperCase(),
          style: TextStyle(
            color: p.isLeader ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      title: Text(p.isMe ? '${p.displayName} (você)' : p.displayName),
      subtitle: Text(
        status,
        style: TextStyle(color: behind ? Colors.orange.shade800 : null),
      ),
      trailing: state.isLeader && !p.isMe
          ? TextButton(
              onPressed: () => _confirmPass(context, p),
              child: const Text('Passar condução'),
            )
          : null,
    );
  }

  // ---------------------------------------------------------------------------

  Future<void> _pickAndPlay(BuildContext context) async {
    final cifra = await showCifraPickerSheet(context, title: 'Tocar agora');
    if (cifra == null || !context.mounted) return;
    await _guard(context, () async {
      await controller.playNow(musicId: cifra.id);
      onAfterPlay?.call();
    });
  }

  Future<void> _pickAndQueue(BuildContext context, LiveRoomState state) async {
    final cifra = await showCifraPickerSheet(
      context,
      title: state.isLeader ? 'Pôr na fila' : 'Sugerir cifra',
    );
    if (cifra == null || !context.mounted) return;
    await _guard(context, () => controller.addToQueue(cifra.id));
    if (context.mounted) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(
          content: Text('"${CifraTitle.parse(cifra.title).name}" foi para a fila'),
        ),
      );
    }
  }

  Future<void> _shareCode(BuildContext context, LiveRoomState state) async {
    await Clipboard.setData(ClipboardData(text: state.code));
    await SharePlus.instance.share(
      ShareParams(
        text:
            '🔴 Sala ao vivo "${state.title}"\n\nNo app do Hinário: Cifras > Playlists > Ao vivo.\nCódigo da sala: ${state.code}',
      ),
    );
  }

  Future<void> _confirmPass(BuildContext context, LiveParticipant p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Passar a condução?'),
        content: Text('${p.displayName} vai escolher as cifras para todos.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(c).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(c).pop(true),
            child: const Text('Passar'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await _guard(context, () => controller.passLeadership(p.id));
    }
  }

  Future<void> _confirmClose(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Encerrar a sala?'),
        content: const Text('A sala fecha para todo mundo que está nela.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(c).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(c).pop(true),
            child: const Text('Encerrar'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      onAfterPlay?.call(); // fecha o painel se ele estiver num bottom sheet
      await _guard(context, controller.closeRoom);
    }
  }
}

/// Executa uma ação da sala mostrando o erro (se houver) num SnackBar.
Future<void> _guard(BuildContext context, Future<void> Function() action) async {
  try {
    await action();
  } on ApiException catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.red),
      );
    }
  }
}
