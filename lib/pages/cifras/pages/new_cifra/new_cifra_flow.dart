import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../api/connection/app_api.dart';
import '../../../../models/cifra.dart';
import '../../../../services/client_identity_service.dart';
import '../../../../services/community_cifra_service.dart';
import '../../../../utils/chords.dart';
import '../../widgets/chord_sheet_view.dart';

const _primary = Color(0xFF3E5A86);

/// "Nova cifra": tirar foto, escolher da galeria ou digitar.
/// Devolve a cifra criada (já salva no aparelho) ou null.
Future<Cifra?> startNewCifra(BuildContext context, {String? suggestedTitle}) async {
  final choice = await showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Nova cifra para a igreja',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              'Ela aparece para todos em Cifras e pode ir para playlists e salas ao vivo.',
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 16),
            _option(
              sheetContext,
              'camera',
              Icons.photo_camera_outlined,
              'Tirar foto',
              'Do papel, da partitura ou da tela de outro celular',
            ),
            _option(
              sheetContext,
              'gallery',
              Icons.photo_library_outlined,
              'Escolher foto',
              'Um print ou foto que já está no celular',
            ),
            _option(
              sheetContext,
              'text',
              Icons.notes_rounded,
              'Digitar ou colar cifra',
              'Estilo Cifra Club: acordes em cima da letra, dá para mudar o tom',
            ),
          ],
        ),
      ),
    ),
  );
  if (choice == null || !context.mounted) return null;
  if (!await ClientIdentityService.instance.ensureName(context)) return null;
  if (!context.mounted) return null;

  if (choice == 'text') {
    return Navigator.of(context).push<Cifra>(
      MaterialPageRoute(
        builder: (_) => TextCifraEditorPage(initialTitle: suggestedTitle),
      ),
    );
  }

  final picked = await ImagePicker().pickImage(
    source: choice == 'camera' ? ImageSource.camera : ImageSource.gallery,
    // Leve para chegar rápido no celular dos outros (~200–400 KB) e ainda
    // nítido para ler acordes.
    maxWidth: 1600,
    maxHeight: 1600,
    imageQuality: 72,
  );
  if (picked == null || !context.mounted) return null;

  return Navigator.of(context).push<Cifra>(
    MaterialPageRoute(
      builder: (_) => PhotoCifraPage(
        image: File(picked.path),
        initialTitle: suggestedTitle,
      ),
    ),
  );
}

Widget _option(
  BuildContext context,
  String value,
  IconData icon,
  String title,
  String subtitle,
) {
  return Card(
    elevation: 0,
    margin: const EdgeInsets.only(bottom: 8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
      side: BorderSide(color: Colors.grey.shade200),
    ),
    child: ListTile(
      leading: CircleAvatar(
        backgroundColor: _primary.withValues(alpha: 0.1),
        child: Icon(icon, color: _primary),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      onTap: () => Navigator.of(context).pop(value),
    ),
  );
}

// -----------------------------------------------------------------------------
// Foto
// -----------------------------------------------------------------------------

class PhotoCifraPage extends StatefulWidget {
  final File image;
  final String? initialTitle;

  const PhotoCifraPage({super.key, required this.image, this.initialTitle});

  @override
  State<PhotoCifraPage> createState() => _PhotoCifraPageState();
}

class _PhotoCifraPageState extends State<PhotoCifraPage> {
  late final TextEditingController _title = TextEditingController(
    text: widget.initialTitle ?? '',
  );
  final TextEditingController _tone = TextEditingController();
  double? _progress;
  String? _error;

  @override
  void dispose() {
    _title.dispose();
    _tone.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_title.text.trim().length < 2) {
      setState(() => _error = 'Dê um nome para a cifra');
      return;
    }
    setState(() {
      _progress = 0;
      _error = null;
    });
    try {
      final cifra = await CommunityCifraService.instance.createFromImage(
        image: widget.image,
        title: _title.text.trim(),
        tone: _tone.text.trim(),
        onProgress: (p) {
          if (mounted) setState(() => _progress = p);
        },
      );
      if (!mounted) return;
      Navigator.of(context).pop(cifra);
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _progress = null;
          _error = e.message;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sending = _progress != null;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Foto como cifra'),
        backgroundColor: _primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: ColoredBox(
              color: const Color(0xFF111827),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 380),
                child: Image.file(widget.image, fit: BoxFit.contain),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _title,
            enabled: !sending,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Nome do hino *',
              hintText: 'Ex.: Por Tua Graça C 73',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _tone,
            enabled: !sending,
            maxLength: 6,
            decoration: const InputDecoration(
              labelText: 'Tom (opcional)',
              hintText: 'Ex.: G',
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            ),
          const SizedBox(height: 8),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: _primary,
              minimumSize: const Size.fromHeight(50),
            ),
            onPressed: sending ? null : _send,
            icon: sending
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.cloud_upload_outlined),
            label: Text(
              sending
                  ? 'Enviando ${((_progress ?? 0) * 100).round()}%'
                  : 'Enviar para a igreja',
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Texto (estilo Cifra Club)
// -----------------------------------------------------------------------------

class TextCifraEditorPage extends StatefulWidget {
  final String? initialTitle;

  /// Para editar uma cifra em texto que eu enviei
  final Cifra? editing;
  final String? initialContent;

  const TextCifraEditorPage({
    super.key,
    this.initialTitle,
    this.editing,
    this.initialContent,
  });

  @override
  State<TextCifraEditorPage> createState() => _TextCifraEditorPageState();
}

class _TextCifraEditorPageState extends State<TextCifraEditorPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 2, vsync: this);
  late final TextEditingController _title = TextEditingController(
    text: widget.editing?.title ?? widget.initialTitle ?? '',
  );
  late final TextEditingController _tone = TextEditingController(
    text: widget.editing?.tone ?? '',
  );
  late final TextEditingController _content = TextEditingController(
    text: widget.initialContent ?? '',
  );
  bool _sending = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabs.addListener(() {
      if (_tabs.index == 1) FocusScope.of(context).unfocus();
      setState(() {});
    });
    _content.addListener(_guessTone);
  }

  void _guessTone() {
    if (_tone.text.isNotEmpty) return;
    final guess = Chords.guessKey(_content.text);
    if (guess != null) _tone.text = guess;
  }

  @override
  void dispose() {
    _tabs.dispose();
    _title.dispose();
    _tone.dispose();
    _content.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final title = _title.text.trim();
    final content = _content.text.trimRight();
    if (title.length < 2) {
      setState(() => _error = 'Dê um nome para a cifra');
      return;
    }
    if (content.trim().length < 5) {
      setState(() => _error = 'Escreva ou cole a cifra');
      return;
    }
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      final service = CommunityCifraService.instance;
      final cifra = widget.editing == null
          ? await service.createText(
              title: title,
              content: content,
              tone: _tone.text.trim(),
            )
          : await service.updateText(
              widget.editing!,
              title: title,
              content: content,
              tone: _tone.text.trim(),
            );
      if (!mounted) return;
      Navigator.of(context).pop(cifra);
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _sending = false;
          _error = e.message;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editing == null ? 'Nova cifra' : 'Editar cifra'),
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _sending ? null : _send,
            child: _sending
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    widget.editing == null ? 'Enviar' : 'Salvar',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Escrever'),
            Tab(text: 'Ver como fica'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _title,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        labelText: 'Nome do hino *',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _tone,
                      maxLength: 6,
                      decoration: const InputDecoration(
                        labelText: 'Tom',
                        counterText: '',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Dica: cole do Cifra Club ou escreva os acordes na linha de cima da letra, alinhados com espaços. '
                  'Também funciona assim: [G]Somos [D]filhos. Use [Refrão] para marcar partes.',
                  style: TextStyle(fontSize: 13),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _content,
                minLines: 14,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontFamilyFallback: ['Menlo', 'Courier New', 'Courier'],
                  fontSize: 14,
                  height: 1.35,
                ),
                decoration: const InputDecoration(
                  alignLabelWithHint: true,
                  labelText: 'Cifra',
                  hintText: '   G          D\nSomos filhos e herdeiros\n   Em        C\nDo Rei da glória',
                ),
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(_error!, style: const TextStyle(color: Colors.red)),
                ),
            ],
          ),
          _content.text.trim().isEmpty
              ? const Center(child: Text('Escreva a cifra para ver a prévia'))
              : ChordSheetView(
                  key: ValueKey(_content.text.hashCode ^ _tone.text.hashCode),
                  content: _content.text,
                  originalKey: _tone.text,
                ),
        ],
      ),
    );
  }
}
