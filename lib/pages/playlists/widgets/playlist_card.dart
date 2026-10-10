import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/playlist.model.dart';
import '../../../utils/date_br.dart';

class PlaylistCard extends StatelessWidget {
  final Playlist playlist;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const PlaylistCard({
    super.key,
    required this.playlist,
    required this.onTap,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
        leading: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFF3E5A86).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const SizedBox(
            width: 44,
            height: 44,
            child: Icon(
              Icons.queue_music_rounded,
              color: Color(0xFF3E5A86),
              size: 24,
            ),
          ),
        ),
        title: Text(
          playlist.title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2D3748),
          ),
          softWrap: true,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (playlist.description.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                playlist.description,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                softWrap: true,
              ),
            ],
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3E5A86).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${playlist.cifraIds.length} ${playlist.cifraIds.length == 1 ? 'cifra' : 'cifras'}',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF3E5A86),
                          ),
                        ),
                      ),
                      if (playlist.isPublishedToChurch)
                        _badge(
                          Icons.groups_rounded,
                          playlist.serviceDateValue != null
                              ? 'Igreja · ${DateBr.short(playlist.serviceDateValue!)}'
                              : 'Igreja',
                          Colors.green.shade700,
                        )
                      else if (playlist.isRemote)
                        _badge(
                          Icons.link_rounded,
                          playlist.remoteCode!,
                          const Color(0xFF3E5A86),
                        ),
                      if (playlist.pendingSync)
                        _badge(
                          Icons.cloud_off_rounded,
                          'Não enviada',
                          Colors.orange.shade800,
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatDate(playlist.updatedAt),
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              onEdit();
            } else if (value == 'delete') {
              onDelete();
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 18),
                  SizedBox(width: 8),
                  Text('Editar'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 18, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Excluir', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          icon: const Icon(Icons.more_vert, size: 20),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _badge(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 3),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return DateFormat('HH:mm').format(date);
    } else if (difference.inDays == 1) {
      return 'Ontem';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d atrás';
    } else {
      return DateFormat('dd/MM').format(date);
    }
  }
}
