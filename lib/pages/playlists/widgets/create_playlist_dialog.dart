import 'package:flutter/material.dart';
import '../../../models/playlist.model.dart';
import '../../../utils/date_br.dart';

class PlaylistFormData {
  final String title;
  final String description;
  final bool publishToChurch;
  final DateTime? serviceDate;

  const PlaylistFormData({
    required this.title,
    required this.description,
    required this.publishToChurch,
    required this.serviceDate,
  });

  String? get serviceDateIso =>
      serviceDate == null ? null : DateBr.iso(serviceDate!);
}

class CreatePlaylistDialog extends StatefulWidget {
  final Playlist? playlist;
  final Future<void> Function(PlaylistFormData data) onCreatePlaylist;

  const CreatePlaylistDialog({
    Key? key,
    this.playlist,
    required this.onCreatePlaylist,
  }) : super(key: key);

  @override
  State<CreatePlaylistDialog> createState() => _CreatePlaylistDialogState();
}

class _CreatePlaylistDialogState extends State<CreatePlaylistDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;
  bool _publishToChurch = false;
  DateTime? _serviceDate;
  String? _dateError;

  @override
  void initState() {
    super.initState();
    final playlist = widget.playlist;
    if (playlist != null) {
      _titleController.text = playlist.title;
      _descriptionController.text = playlist.description;
      _publishToChurch = playlist.isPublishedToChurch;
      _serviceDate = playlist.serviceDateValue;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.playlist != null;

    return AlertDialog(
      scrollable: true,
      title: Text(isEditing ? 'Editar Playlist' : 'Nova Playlist'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Título *',
                hintText: 'Ex: Reunião de Sábado à Noite',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Digite um título para a playlist';
                }
                if (value.trim().length < 3) {
                  return 'O título deve ter pelo menos 3 caracteres';
                }
                return null;
              },
              textCapitalization: TextCapitalization.words,
              maxLength: 50,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descrição (opcional)',
                hintText: 'Descreva o propósito desta playlist',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              maxLength: 200,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.event),
              label: Text(
                _serviceDate == null
                    ? 'Data do culto (opcional)'
                    : 'Culto: ${DateBr.short(_serviceDate!)}',
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(44),
              ),
            ),
            if (_dateError != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  _dateError!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _publishToChurch,
              onChanged: (value) => setState(() {
                _publishToChurch = value;
                _dateError = null;
              }),
              title: const Text('Publicar para a igreja'),
              subtitle: const Text(
                'Aparece para todos na aba "Da igreja". Só você pode editar.',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3E5A86),
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(isEditing ? 'Salvar' : 'Criar'),
        ),
      ],
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _serviceDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1, 12, 31),
      helpText: 'Data do culto',
    );
    if (picked != null) {
      setState(() {
        _serviceDate = picked;
        _dateError = null;
      });
    }
  }

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_publishToChurch && _serviceDate == null) {
      setState(() => _dateError = 'Escolha a data do culto para publicar');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await widget.onCreatePlaylist(
        PlaylistFormData(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          publishToChurch: _publishToChurch,
          serviceDate: _serviceDate,
        ),
      );

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
