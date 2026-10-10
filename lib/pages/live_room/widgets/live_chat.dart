import 'package:flutter/material.dart';

import '../../../api/connection/app_api.dart';
import '../../../models/live_room.model.dart';
import '../live_room_controller.dart';

const _primary = Color(0xFF3E5A86);

const _quickReplies = [
  '👍',
  'Qual o tom?',
  'Pode ser!',
  'Mais devagar',
  'Repete o refrão',
  'Próxima?',
];

String _time(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

/// Aviso discreto por cima da cifra quando chega mensagem.
/// Fica no topo, some sozinho em 6s, toque abre o chat, arraste para cima fecha.
class LiveChatBanner extends StatelessWidget {
  final LiveRoomController controller;
  final VoidCallback onOpenChat;
  final String Function(int) titleOf;

  const LiveChatBanner({
    super.key,
    required this.controller,
    required this.onOpenChat,
    required this.titleOf,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 8,
      left: 12,
      right: 12,
      child: ValueListenableBuilder<LiveChatMessage?>(
        valueListenable: controller.banner,
        builder: (context, message, _) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            transitionBuilder: (child, animation) => SlideTransition(
              position: Tween(
                begin: const Offset(0, -1.2),
                end: Offset.zero,
              ).animate(animation),
              child: FadeTransition(opacity: animation, child: child),
            ),
            child: message == null
                ? const SizedBox.shrink(key: ValueKey('none'))
                : Dismissible(
                    key: ValueKey('msg-${message.id}'),
                    direction: DismissDirection.up,
                    onDismissed: (_) => controller.dismissBanner(),
                    child: Material(
                      elevation: 6,
                      color: const Color(0xF21F2937),
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: onOpenChat,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(10, 8, 6, 8),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: Colors.white24,
                                child: Text(
                                  message.displayName.characters.first.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      message.displayName,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      message.text.isNotEmpty
                                          ? message.text
                                          : '🎵 ${titleOf(message.musicId!)}',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                onPressed: controller.dismissBanner,
                                icon: const Icon(
                                  Icons.close,
                                  size: 18,
                                  color: Colors.white54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
          );
        },
      ),
    );
  }
}

/// Abre o chat por cima da tela atual (a cifra continua atrás).
Future<void> showLiveChatSheet(
  BuildContext context, {
  required LiveRoomController controller,
  required String Function(int) titleOf,
  required void Function(int musicId) onOpenCifra,
}) async {
  controller.setChatOpen(true);
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: const Color(0xFFF6F7FB),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
      ),
      child: SizedBox(
        height: MediaQuery.sizeOf(sheetContext).height * 0.62,
        child: _LiveChat(
          controller: controller,
          titleOf: titleOf,
          onOpenCifra: (id) {
            Navigator.of(sheetContext).pop();
            onOpenCifra(id);
          },
        ),
      ),
    ),
  );
  controller.setChatOpen(false);
}

class _LiveChat extends StatefulWidget {
  final LiveRoomController controller;
  final String Function(int) titleOf;
  final void Function(int musicId) onOpenCifra;

  const _LiveChat({
    required this.controller,
    required this.titleOf,
    required this.onOpenCifra,
  });

  @override
  State<_LiveChat> createState() => _LiveChatState();
}

class _LiveChatState extends State<_LiveChat> {
  final TextEditingController _input = TextEditingController();
  bool _attachCurrent = false;
  bool _sending = false;

  LiveRoomController get c => widget.controller;

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  Future<void> _send(String text) async {
    final trimmed = text.trim();
    final current = c.state?.current?.musicId;
    final musicId = _attachCurrent ? current : null;
    if (trimmed.isEmpty && musicId == null) return;
    setState(() => _sending = true);
    try {
      await c.sendMessage(trimmed, musicId: musicId);
      _input.clear();
      setState(() => _attachCurrent = false);
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: c,
      builder: (context, _) {
        final messages = c.messages.reversed.toList();
        final current = c.state?.current?.musicId;
        return Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
              child: Row(
                children: [
                  const Icon(Icons.forum_outlined, color: _primary, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Conversa da sala',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  Text(
                    'some quando a sala fecha',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            Expanded(
              child: messages.isEmpty
                  ? Center(
                      child: Text(
                        'Ninguém falou nada ainda.\nCombine o tom, a ordem, o que precisar.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    )
                  : ListView.builder(
                      reverse: true,
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final m = messages[index];
                        final older = index + 1 < messages.length
                            ? messages[index + 1]
                            : null;
                        final showName =
                            !m.isMe && (older == null || older.authorId != m.authorId);
                        return _bubble(m, showName);
                      },
                    ),
            ),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  for (final reply in _quickReplies)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ActionChip(
                        label: Text(reply),
                        onPressed: _sending ? null : () => _send(reply),
                        backgroundColor: Colors.white,
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: const StadiumBorder(),
                      ),
                    ),
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
                child: Row(
                  children: [
                    if (current != null)
                      IconButton(
                        tooltip: 'Citar a cifra de agora',
                        onPressed: () =>
                            setState(() => _attachCurrent = !_attachCurrent),
                        icon: Icon(
                          Icons.music_note_rounded,
                          color: _attachCurrent ? _primary : Colors.grey,
                        ),
                      ),
                    Expanded(
                      child: TextField(
                        controller: _input,
                        minLines: 1,
                        maxLines: 4,
                        maxLength: 500,
                        textCapitalization: TextCapitalization.sentences,
                        onSubmitted: _send,
                        decoration: InputDecoration(
                          counterText: '',
                          hintText: _attachCurrent && current != null
                              ? 'Sobre "${widget.titleOf(current)}"...'
                              : 'Mensagem',
                          filled: true,
                          fillColor: Colors.white,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(22),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(22),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    IconButton.filled(
                      style: IconButton.styleFrom(backgroundColor: _primary),
                      onPressed: _sending ? null : () => _send(_input.text),
                      icon: _sending
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.send_rounded, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _bubble(LiveChatMessage m, bool showName) {
    final mine = m.isMe;
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.78,
        ),
        child: Container(
          margin: EdgeInsets.only(top: showName ? 10 : 3),
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
          decoration: BoxDecoration(
            color: mine ? _primary : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(mine ? 16 : 4),
              bottomRight: Radius.circular(mine ? 4 : 16),
            ),
            border: mine ? null : Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showName)
                Text(
                  m.displayName,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _primary,
                  ),
                ),
              if (m.musicId != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2, bottom: 4),
                  child: InkWell(
                    onTap: () => widget.onOpenCifra(m.musicId!),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: mine
                            ? Colors.white.withValues(alpha: 0.18)
                            : _primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.music_note_rounded,
                            size: 14,
                            color: mine ? Colors.white : _primary,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              widget.titleOf(m.musicId!),
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: mine ? Colors.white : _primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (m.text.isNotEmpty)
                Text(
                  m.text,
                  style: TextStyle(
                    fontSize: 15,
                    color: mine ? Colors.white : const Color(0xFF1F2937),
                  ),
                ),
              const SizedBox(height: 2),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  _time(m.createdAt),
                  style: TextStyle(
                    fontSize: 10,
                    color: mine ? Colors.white60 : Colors.grey.shade500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
