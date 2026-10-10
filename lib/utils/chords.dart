/// Utilidades para cifra em texto (estilo Cifra Club): acordes numa linha,
/// letra na linha de baixo. Também aceita acordes entre colchetes: "[G]Somos".
class Chords {
  static const _sharp = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'];
  static const _flat = ['C', 'Db', 'D', 'Eb', 'E', 'F', 'Gb', 'G', 'Ab', 'A', 'Bb', 'B'];

  /// Tons que costumam ser escritos com bemol
  static const _flatKeys = {'F', 'Bb', 'Eb', 'Ab', 'Db', 'Gb', 'Dm', 'Gm', 'Cm', 'Fm', 'Bbm', 'Ebm'};

  /// Acorde: raiz + (sustenido/bemol) + qualidade/extensões + baixo opcional.
  /// Ex.: G, Am7, F#m7(b5), C/E, D4(9), Bb7M, E7(#9), A°, Gsus4
  static final RegExp chordRegex = RegExp(
    r'^\(?([A-G])([#b]?)((?:m|M|maj|min|dim|aug|sus|add|°|º|\+|-|\d|\(|\)|#|b|/(?![A-G]))*?)(?:/([A-G])([#b]?))?\)?$',
  );

  static final RegExp _token = RegExp(r'\S+');

  static int? _index(String root, String accidental) {
    final name = root + accidental;
    var i = _sharp.indexOf(name);
    if (i >= 0) return i;
    i = _flat.indexOf(name);
    if (i >= 0) return i;
    // E#, B#, Fb, Cb
    final base = _sharp.indexOf(root);
    if (base < 0) return null;
    if (accidental == '#') return (base + 1) % 12;
    if (accidental == 'b') return (base + 11) % 12;
    return base;
  }

  static bool isChord(String token) {
    if (token.isEmpty || token.length > 14) return false;
    return chordRegex.hasMatch(token);
  }

  /// Linha de acordes: todos os "pedaços" são acordes (ou separadores).
  static bool isChordLine(String line) {
    final tokens = _token
        .allMatches(line)
        .map((m) => m.group(0)!)
        .where((t) => !_isSeparator(t))
        .toList();
    if (tokens.isEmpty) return false;
    final chords = tokens.where(isChord).length;
    // tolera um "x2" ou "(2x)" perdido na linha
    return chords >= 1 && chords >= tokens.length - (tokens.length > 3 ? 1 : 0);
  }

  static bool _isSeparator(String t) =>
      RegExp(r'^(\||-+|/|\.+|\(?x?\d+x?\)?|:|\[|\])$', caseSensitive: false)
          .hasMatch(t);

  static String transposeChord(String chord, int semitones, {bool preferFlat = false}) {
    if (semitones % 12 == 0) return chord;
    final m = chordRegex.firstMatch(chord);
    if (m == null) return chord;
    final names = preferFlat ? _flat : _sharp;

    String shift(String root, String acc) {
      final i = _index(root, acc);
      if (i == null) return root + acc;
      return names[((i + semitones) % 12 + 12) % 12];
    }

    final openParen = chord.startsWith('(') ? '(' : '';
    final closeParen = chord.endsWith(')') && openParen.isNotEmpty ? ')' : '';
    final root = shift(m.group(1)!, m.group(2) ?? '');
    final quality = m.group(3) ?? '';
    final bass = m.group(4) == null ? '' : '/${shift(m.group(4)!, m.group(5) ?? '')}';
    return '$openParen$root$quality$bass$closeParen';
  }

  /// Transpõe uma linha de acordes mantendo o alinhamento com a letra.
  static String transposeChordLine(String line, int semitones, {bool preferFlat = false}) {
    if (semitones % 12 == 0) return line;
    final buffer = StringBuffer();
    var last = 0;
    var debt = 0; // quantos espaços "pegamos emprestado" quando o acorde cresceu
    for (final m in _token.allMatches(line)) {
      var gap = line.substring(last, m.start);
      if (debt > 0 && gap.length > 1) {
        final take = debt < gap.length - 1 ? debt : gap.length - 1;
        gap = gap.substring(take);
        debt -= take;
      }
      buffer.write(gap);
      final token = m.group(0)!;
      final out = isChord(token)
          ? transposeChord(token, semitones, preferFlat: preferFlat)
          : token;
      buffer.write(out);
      if (out.length > token.length) debt += out.length - token.length;
      if (out.length < token.length) buffer.write(' ' * (token.length - out.length));
      last = m.end;
    }
    buffer.write(line.substring(last));
    return buffer.toString();
  }

  /// Transpõe acordes entre colchetes no meio da letra: "[G]Somos [D]filhos".
  static String transposeInline(String line, int semitones, {bool preferFlat = false}) {
    return line.replaceAllMapped(
      RegExp(r'\[([^\]\s]{1,14})\]'),
      (m) => isChord(m.group(1)!)
          ? '[${transposeChord(m.group(1)!, semitones, preferFlat: preferFlat)}]'
          : m.group(0)!,
    );
  }

  /// Nome do tom depois de transpor (para mostrar "Tom: A").
  static String? transposeKey(String? key, int semitones) {
    if (key == null || key.trim().isEmpty) return null;
    final k = key.trim();
    if (!isChord(k)) return k;
    final preferFlat = _flatKeys.contains(k);
    return transposeChord(k, semitones, preferFlat: preferFlat);
  }

  static bool prefersFlat(String? key) => key != null && _flatKeys.contains(key.trim());

  /// Tenta adivinhar o tom pelo primeiro acorde da cifra.
  static String? guessKey(String content) {
    for (final line in content.split('\n')) {
      if (isChordLine(line)) {
        final first = _token.allMatches(line).map((m) => m.group(0)!).firstWhere(
          isChord,
          orElse: () => '',
        );
        if (first.isEmpty) continue;
        final m = chordRegex.firstMatch(first);
        if (m == null) continue;
        final minor = (m.group(3) ?? '').startsWith('m') &&
            !(m.group(3) ?? '').startsWith('maj');
        return '${m.group(1)}${m.group(2) ?? ''}${minor ? 'm' : ''}';
      }
    }
    return null;
  }
}
