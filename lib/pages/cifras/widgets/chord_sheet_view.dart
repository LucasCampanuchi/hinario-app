import 'package:flutter/material.dart';

import '../../../utils/chords.dart';

const _chordColor = Color(0xFFE8711A);
const _primary = Color(0xFF3E5A86);

/// Mostra uma cifra em texto (acordes em cima da letra), com
/// mudança de tom e tamanho de letra.
class ChordSheetView extends StatefulWidget {
  final String content;
  final String? originalKey;

  const ChordSheetView({super.key, required this.content, this.originalKey});

  @override
  State<ChordSheetView> createState() => _ChordSheetViewState();
}

class _ChordSheetViewState extends State<ChordSheetView> {
  int _semitones = 0;
  double? _fontSize; // null = ajustar à largura da tela

  late String _key;

  @override
  void initState() {
    super.initState();
    _key = widget.originalKey?.trim().isNotEmpty == true
        ? widget.originalKey!.trim()
        : (Chords.guessKey(widget.content) ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final preferFlat = Chords.prefersFlat(Chords.transposeKey(_key, _semitones));
    final lines = widget.content.replaceAll('\r\n', '\n').split('\n');
    final longest = lines.fold<int>(0, (m, l) => l.length > m ? l.length : m);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth - 32;
        final fitted = longest == 0
            ? 16.0
            : (width / (longest * 0.62)).clamp(11.0, 20.0).toDouble();
        final size = _fontSize ?? fitted;

        return Column(
          children: [
            _toolbar(size, fitted),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SelectionArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final line in lines)
                          _line(line, size, preferFlat),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _toolbar(double size, double fitted) {
    final key = Chords.transposeKey(_key, _semitones);
    return Material(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            IconButton(
              tooltip: 'Meio tom abaixo',
              onPressed: () => setState(() => _semitones--),
              icon: const Icon(Icons.remove_circle_outline),
            ),
            GestureDetector(
              onTap: _semitones == 0 ? null : () => setState(() => _semitones = 0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    key == null || key.isEmpty ? 'Tom' : 'Tom: $key',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: _chordColor,
                    ),
                  ),
                  Text(
                    _semitones == 0
                        ? 'original'
                        : '${_semitones > 0 ? '+' : ''}$_semitones · toque p/ voltar',
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Meio tom acima',
              onPressed: () => setState(() => _semitones++),
              icon: const Icon(Icons.add_circle_outline),
            ),
            const Spacer(),
            IconButton(
              tooltip: 'Letra menor',
              onPressed: () => setState(() => _fontSize = (size - 1).clamp(9.0, 32.0).toDouble()),
              icon: const Icon(Icons.text_decrease_rounded),
            ),
            IconButton(
              tooltip: 'Letra maior',
              onPressed: () => setState(() => _fontSize = (size + 1).clamp(9.0, 32.0).toDouble()),
              icon: const Icon(Icons.text_increase_rounded),
            ),
            if (_fontSize != null)
              IconButton(
                tooltip: 'Ajustar à tela',
                onPressed: () => setState(() => _fontSize = null),
                icon: const Icon(Icons.fit_screen_rounded, color: _primary),
              ),
          ],
        ),
      ),
    );
  }

  TextStyle _base(double size) => TextStyle(
    fontFamily: 'monospace',
    fontFamilyFallback: const ['Menlo', 'Courier New', 'Courier'],
    fontSize: size,
    height: 1.35,
    color: const Color(0xFF1F2937),
  );

  Widget _line(String raw, double size, bool preferFlat) {
    final base = _base(size);

    if (raw.trim().isEmpty) return SizedBox(height: size * 0.9);

    // Rótulos de parte: [Refrão], Refrão:, INTRO:
    final label = RegExp(r'^\s*\[([^\]]{2,30})\]\s*$').firstMatch(raw);
    if (label != null && !Chords.isChord(label.group(1)!)) {
      return Padding(
        padding: EdgeInsets.only(top: size * 0.5, bottom: 2),
        child: Text(
          label.group(1)!,
          style: base.copyWith(
            fontWeight: FontWeight.w700,
            color: _primary,
          ),
        ),
      );
    }

    if (Chords.isChordLine(raw)) {
      final line = Chords.transposeChordLine(raw, _semitones, preferFlat: preferFlat);
      return Text.rich(
        TextSpan(children: _chordSpans(line, base)),
        softWrap: false,
      );
    }

    // Acordes no meio da letra: [G]Somos [D]filhos
    if (raw.contains('[')) {
      final line = Chords.transposeInline(raw, _semitones, preferFlat: preferFlat);
      final spans = <InlineSpan>[];
      var last = 0;
      for (final m in RegExp(r'\[([^\]\s]{1,14})\]').allMatches(line)) {
        spans.add(TextSpan(text: line.substring(last, m.start), style: base));
        final chord = m.group(1)!;
        spans.add(
          TextSpan(
            text: Chords.isChord(chord) ? chord : '[$chord]',
            style: Chords.isChord(chord) ? _chordStyle(base) : base,
          ),
        );
        last = m.end;
      }
      spans.add(TextSpan(text: line.substring(last), style: base));
      return Text.rich(TextSpan(children: spans), softWrap: false);
    }

    final isSection = RegExp(r'^\s*[A-Za-zÀ-ú ]{2,20}:\s*$').hasMatch(raw);
    return Text(
      raw,
      softWrap: false,
      style: isSection
          ? base.copyWith(fontWeight: FontWeight.w700, color: _primary)
          : base,
    );
  }

  TextStyle _chordStyle(TextStyle base) =>
      base.copyWith(color: _chordColor, fontWeight: FontWeight.w700);

  List<InlineSpan> _chordSpans(String line, TextStyle base) {
    final spans = <InlineSpan>[];
    var last = 0;
    for (final m in RegExp(r'\S+').allMatches(line)) {
      spans.add(TextSpan(text: line.substring(last, m.start), style: base));
      final token = m.group(0)!;
      spans.add(
        TextSpan(
          text: token,
          style: Chords.isChord(token) ? _chordStyle(base) : base.copyWith(color: Colors.grey.shade600),
        ),
      );
      last = m.end;
    }
    spans.add(TextSpan(text: line.substring(last), style: base));
    return spans;
  }
}
