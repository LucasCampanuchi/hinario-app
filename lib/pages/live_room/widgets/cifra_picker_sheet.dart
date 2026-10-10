import 'package:flutter/material.dart';

import '../../../models/cifra.dart';
import '../../../services/cifra_lookup_service.dart';
import '../../../utils/cifra_title.dart';

/// Abre uma lista pesquisável das cifras baixadas e devolve a escolhida.
Future<Cifra?> showCifraPickerSheet(
  BuildContext context, {
  String title = 'Escolher cifra',
}) {
  return showModalBottomSheet<Cifra>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) =>
          _CifraPicker(title: title, scrollController: scrollController),
    ),
  );
}

class _CifraPicker extends StatefulWidget {
  final String title;
  final ScrollController scrollController;

  const _CifraPicker({required this.title, required this.scrollController});

  @override
  State<_CifraPicker> createState() => _CifraPickerState();
}

class _CifraPickerState extends State<_CifraPicker> {
  List<Cifra> _all = [];
  String _query = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    CifraLookupService.instance.all(refresh: true).then((map) {
      if (!mounted) return;
      final list = map.values.toList()..sort((a, b) => b.id.compareTo(a.id));
      setState(() {
        _all = list;
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = CifraSearch.tokens(_query);
    final results = tokens.isEmpty
        ? _all
        : (_all
                  .map((c) => (c, CifraSearch.score(c.title, tokens)))
                  .where((e) => e.$2 > 0)
                  .toList()
                ..sort((a, b) => b.$2.compareTo(a.$2)))
              .map((e) => e.$1)
              .toList();

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
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Text(
            widget.title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            autofocus: true,
            onChanged: (value) => setState(() => _query = value),
            decoration: InputDecoration(
              hintText: 'Nome ou número do hino...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : results.isEmpty
              ? const Center(child: Text('Nenhuma cifra encontrada'))
              : ListView.builder(
                  controller: widget.scrollController,
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final cifra = results[index];
                    final t = CifraTitle.parse(cifra.title);
                    final details = [
                      if (t.hymnRef != null) 'Hino ${t.hymnRef}',
                      ...t.chips,
                      if (t.status != null) t.status!,
                      if (cifra.authorName != null) 'por ${cifra.authorName}',
                    ].join(' · ');
                    return ListTile(
                      leading: Icon(
                        cifra.kind == 'image'
                            ? Icons.photo_outlined
                            : cifra.kind == 'text'
                            ? Icons.notes_rounded
                            : Icons.music_note_rounded,
                      ),
                      title: Text(
                        t.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: details.isEmpty ? null : Text(details),
                      enabled: cifra.localFilePath != null,
                      onTap: () => Navigator.of(context).pop(cifra),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
