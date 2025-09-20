import 'package:flutter/material.dart';
import '../../../models/playlist.model.dart';

class CreatePlaylistDialog extends StatefulWidget {
  final Playlist? playlist;
  final Function(String title, String description) onCreatePlaylist;

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

  @override
  void initState() {
    super.initState();
    if (widget.playlist != null) {
      _titleController.text = widget.playlist!.title;
      _descriptionController.text = widget.playlist!.description;
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

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await widget.onCreatePlaylist(
        _titleController.text.trim(),
        _descriptionController.text.trim(),
      );

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: $e'),
            backgroundColor: Colors.red,
          ),
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
