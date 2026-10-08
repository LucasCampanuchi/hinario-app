import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../../models/book.model.dart';
import '../../../../../models/bible_verse_annotation.model.dart';
import '../../../../../models/verse.model.dart';
import '../../../../../services/bible_verse_annotation_service.dart';
import '../components/verse_appbar.dart';
import '../components/verse_text.dart';
import '../store/verses.store.dart';

class VersesPage extends StatefulWidget {
  final BookModel book;
  final int chapter;
  final int? verse;

  const VersesPage({
    Key? key,
    required this.book,
    required this.chapter,
    required this.verse,
  }) : super(key: key);

  @override
  State<VersesPage> createState() => _VersesPageState();
}

class _VersesPageState extends State<VersesPage> {
  final VersesStore controller = GetIt.I.get<VersesStore>();
  final BibleVerseAnnotationService _annotationService =
      BibleVerseAnnotationService();
  final Set<int> _selectedVerseIds = <int>{};
  Map<int, BibleVerseAnnotation> _annotations = <int, BibleVerseAnnotation>{};

  @override
  void initState() {
    controller.list(
      context,
      widget.book,
      widget.chapter,
      (widget.verse != null ? (widget.verse!) : 0),
    );

    controller.saveHistory(widget.chapter, widget.book);

    _loadAnnotations();

    super.initState();
  }

  Future<void> _loadAnnotations() async {
    final annotations = await _annotationService.load();
    if (!mounted) return;
    setState(() => _annotations = annotations);
  }

  Future<void> _toggleFavoriteSelection() async {
    if (_selectedVerseIds.isEmpty) return;

    final shouldFavorite = _selectedVerseIds.any(
      (id) => !(_annotations[id]?.favorite ?? false),
    );
    setState(() {
      for (final verse in _selectedVerses) {
        final annotation = _annotationFor(verse);
        _annotations[verse.id!] = annotation.copyWith(favorite: shouldFavorite);
      }
    });
    await _annotationService.save(_annotations);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          shouldFavorite
              ? 'Versículo${_selectedVerseIds.length == 1 ? '' : 's'} favoritado${_selectedVerseIds.length == 1 ? '' : 's'}.'
              : 'Favorito${_selectedVerseIds.length == 1 ? '' : 's'} removido${_selectedVerseIds.length == 1 ? '' : 's'}.',
        ),
      ),
    );
  }

  Future<void> _shareSelection() async {
    final verses = _selectedVerses;
    if (verses.isEmpty || controller.book == null) return;

    final reference =
        '${controller.book!.name} ${controller.chapter + 1}:'
        '${verses.map((verse) => verse.verse).join(', ')}';
    final text = verses
        .map((verse) => '${verse.verse}. ${verse.text}')
        .join('\n');
    await SharePlus.instance.share(ShareParams(text: '$reference\n\n$text'));
  }

  List<VerseModel> get _selectedVerses {
    if (controller.chapter < 0 ||
        controller.chapter >= controller.listVerses.length) {
      return <VerseModel>[];
    }
    return controller.listVerses[controller.chapter]
        .where(
          (verse) => verse.id != null && _selectedVerseIds.contains(verse.id),
        )
        .toList();
  }

  BibleVerseAnnotation _annotationFor(VerseModel verse) {
    final existing = verse.id == null ? null : _annotations[verse.id];
    if (existing != null) return existing;
    return BibleVerseAnnotation(
      verseId: verse.id!,
      bookId: widget.book.id!,
      bookName: widget.book.name ?? '',
      chapter: verse.chapter ?? widget.chapter,
      verse: verse.verse ?? 0,
      text: verse.text ?? '',
    );
  }

  Future<void> _showMarkingSheet() async {
    if (_selectedVerseIds.isEmpty) return;
    final selected = _selectedVerses;
    final noteController = TextEditingController(
      text: selected.length == 1
          ? _annotationFor(selected.first).note ?? ''
          : '',
    );
    int? colorValue = selected.length == 1
        ? _annotationFor(selected.first).colorValue
        : null;
    const colors = <Color>[
      Color(0xFFFFF59D),
      Color(0xFFA5D6A7),
      Color(0xFF90CAF9),
      Color(0xFFF8BBD0),
      Color(0xFFD1C4E9),
      Color(0xFFFFCC80),
    ];

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            20,
            24,
            MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Marcar ${_selectionReference()}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: colors
                    .map(
                      (color) => InkWell(
                        onTap: () =>
                            setSheetState(() => colorValue = color.toARGB32()),
                        borderRadius: BorderRadius.circular(24),
                        child: CircleAvatar(
                          backgroundColor: color,
                          child: colorValue == color.toARGB32()
                              ? const Icon(Icons.check, color: Colors.black87)
                              : null,
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: noteController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Anotação (opcional)',
                  hintText: 'Escreva uma observação sobre este versículo',
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  TextButton(
                    onPressed: () async {
                      setState(() {
                        for (final verse in selected) {
                          _annotations[verse.id!] = _annotationFor(
                            verse,
                          ).copyWith(clearColor: true, clearNote: true);
                        }
                      });
                      await _annotationService.save(_annotations);
                      if (sheetContext.mounted) Navigator.pop(sheetContext);
                    },
                    child: const Text('Remover marcação'),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: () async {
                      setState(() {
                        for (final verse in selected) {
                          _annotations[verse.id!] = _annotationFor(verse)
                              .copyWith(
                                colorValue: colorValue,
                                note: noteController.text.trim(),
                                clearNote: noteController.text.trim().isEmpty,
                              );
                        }
                      });
                      await _annotationService.save(_annotations);
                      if (sheetContext.mounted) Navigator.pop(sheetContext);
                    },
                    child: const Text('Salvar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    noteController.dispose();
  }

  String _selectionReference() {
    final verses = _selectedVerses.map((verse) => verse.verse).join(', ');
    return '${widget.book.name} ${controller.chapter + 1}:$verses';
  }

  void _toggleSelection(VerseModel verse) {
    if (verse.id == null) return;
    setState(() {
      if (!_selectedVerseIds.add(verse.id!)) {
        _selectedVerseIds.remove(verse.id);
      }
    });
  }

  void _clearSelection() => setState(_selectedVerseIds.clear);

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final VerseAppBar standardAppBar = VerseAppBar(appBar: AppBar());
    final bool selecting = _selectedVerseIds.isNotEmpty;

    return Scaffold(
      appBar: selecting
          ? AppBar(
              leading: IconButton(
                tooltip: 'Cancelar seleção',
                onPressed: _clearSelection,
                icon: const Icon(Icons.close),
              ),
              title: Text(_selectionReference()),
              actions: [
                IconButton(
                  tooltip: 'Marcar e anotar',
                  onPressed: _showMarkingSheet,
                  icon: const Icon(Icons.format_paint_outlined),
                ),
                IconButton(
                  tooltip: 'Favoritar',
                  onPressed: _toggleFavoriteSelection,
                  icon: Icon(
                    _selectedVerseIds.every(
                          (id) => _annotations[id]?.favorite ?? false,
                        )
                        ? Icons.star
                        : Icons.star_border,
                  ),
                ),
                IconButton(
                  tooltip: 'Compartilhar',
                  onPressed: _shareSelection,
                  icon: const Icon(Icons.share),
                ),
              ],
            )
          : standardAppBar,
      body: SafeArea(
        top: false,
        child: Observer(
          builder: (_) {
            return Stack(
              fit: StackFit.expand,
              children: [
                PageView(
                  onPageChanged: (value) {
                    _clearSelection();
                    controller.chapter = value;
                    controller.savePage(0);
                  },
                  controller: controller.pageController,
                  children: <Widget>[
                    for (int i = 0; i < controller.listVerses.length; i++)
                      ScrollablePositionedList.builder(
                        itemCount: controller.listVerses[i].length,
                        itemBuilder: (c, index) {
                          final verse = controller.listVerses[i][index];
                          return VerseText(
                            verse: verse,
                            selected:
                                verse.id != null &&
                                _selectedVerseIds.contains(verse.id),
                            favorite:
                                verse.id != null &&
                                (_annotations[verse.id]?.favorite ?? false),
                            markingColor:
                                verse.id == null ||
                                    _annotations[verse.id]?.colorValue == null
                                ? null
                                : Color(_annotations[verse.id]!.colorValue!),
                            hasNote:
                                verse.id != null &&
                                (_annotations[verse.id]?.note?.isNotEmpty ??
                                    false),
                            onLongPress: () => _toggleSelection(verse),
                            onTap: _selectedVerseIds.isEmpty
                                ? null
                                : () => _toggleSelection(verse),
                          );
                        },
                        itemScrollController: controller.listItemController[i],
                        itemPositionsListener:
                            controller.listItemPositionsListener[i],
                      ),
                  ],
                ),
                if (controller.loading)
                  const ColoredBox(
                    color: Colors.white,
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
