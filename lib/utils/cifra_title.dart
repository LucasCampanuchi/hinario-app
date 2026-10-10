/// Lê os títulos do "Serviço de Música" e separa o que importa.
///
/// Ex.: "328 SERVIÇO DE MUSICA  HINO  POR TUA GRAÇA C 73  CIFRA  CORRETA"
///   -> nome "Por Tua Graça", hino "C 73", tags [Cifra], corrigida, nº 328
class CifraTitle {
  /// Título original, exatamente como veio da API.
  final String original;

  /// Nome limpo para mostrar ("Por Tua Graça").
  final String name;

  /// Número do post do Serviço de Música ("328").
  final String? seq;

  /// Referência do hino: "321", "C 73", "S 92".
  final String? hymnRef;

  /// Instrumento/tipo: Cifra, Sax alto, Violão...
  final List<String> kinds;

  /// Ajuste de tom indicado no título ("1 tom abaixo (A)").
  final String? toneHint;

  /// "Corrigida"/"Atualizada" quando o título diz que é a versão certa.
  final String? status;

  const CifraTitle._({
    required this.original,
    required this.name,
    this.seq,
    this.hymnRef,
    this.kinds = const [],
    this.toneHint,
    this.status,
  });

  bool get isCorrected => status != null;

  bool get isSax => kinds.any((k) => k.startsWith('Sax'));

  /// Rótulos curtos para chips (sem o hino e sem o status).
  List<String> get chips => [...kinds, if (toneHint != null) toneHint!];

  // ---------------------------------------------------------------------------

  static final Map<String, CifraTitle> _cache = {};

  static CifraTitle parse(String title) {
    final cached = _cache[title];
    if (cached != null) return cached;
    final parsed = _parse(title);
    if (_cache.length > 3000) _cache.clear();
    _cache[title] = parsed;
    return parsed;
  }

  static const _small = {
    'de', 'da', 'do', 'dos', 'das', 'e', 'a', 'o', 'os', 'as', 'no', 'na',
    'nos', 'nas', 'em', 'ao', 'aos', 'por', 'com', 'para', 'um', 'uma', 'que',
  };

  static final List<(RegExp, String, bool)> _tags = [
    (RegExp(r'\bSAX\s+ALTO\b'), 'Sax alto', false),
    (RegExp(r'\bSAX\s+TENOR\b'), 'Sax tenor', false),
    (RegExp(r'\bSAX\b'), 'Sax', false),
    (RegExp(r'\bVERSAO\s+VIOLAO\b'), 'Violão', false),
    (RegExp(r'\bVIOLAO\b'), 'Violão', false),
    (RegExp(r'\bTECLADO\b'), 'Teclado', false),
    (RegExp(r'\bPARTITURA\b'), 'Partitura', false),
    (RegExp(r'\bVOZ\s+MASCULIN[AO]\b'), 'Voz masculina', false),
    (RegExp(r'\bVOZ\s+FEMININ[AO]\b'), 'Voz feminina', false),
    (RegExp(r'\bCIFRAS?\b'), 'Cifra', false),
    (RegExp(r'\bCORRIGID[AO]\b'), 'Corrigida', true),
    (RegExp(r'\bCORRET[AO]\b'), 'Corrigida', true),
    (RegExp(r'\bATUALIZAD[AO]\b'), 'Atualizada', true),
  ];

  static CifraTitle _parse(String title) {
    final s = title.replaceAll(RegExp(r'\s+'), ' ').trim();
    // Versão sem acento e maiúscula, com o MESMO tamanho (índices batem)
    var u = stripAccentsSameLength(s).toUpperCase();
    // toUpperCase pode mudar o tamanho (ex.: ß); aí trabalhamos só com u
    final base = u.length == s.length ? s : u;
    if (u.length != base.length) u = base;
    final mask = base.split('');
    void kill(int a, int b) {
      for (var i = a; i < b && i < mask.length; i++) {
        mask[i] = '\u0000';
      }
    }

    bool free(int a, int b) {
      for (var i = a; i < b && i < mask.length; i++) {
        if (mask[i] == '\u0000') return false;
      }
      return true;
    }

    String? seq;
    final seqMatch = RegExp(r'^(\d{1,4})\s+').firstMatch(u);
    if (seqMatch != null) {
      seq = seqMatch.group(1);
      kill(seqMatch.start, seqMatch.end);
    }

    for (final m in RegExp(r'\bSERVICO\s+DE\s+MUSICA\b').allMatches(u)) {
      kill(m.start, m.end);
    }

    String? ref;
    final hino = RegExp(r'\bHINO\s+(\d{1,4})\b').firstMatch(u);
    if (hino != null) {
      ref = hino.group(1);
      kill(hino.start, hino.end);
    } else {
      final cs = RegExp(r'\b([CS])\s*-?\s*0*(\d{1,3})\b').firstMatch(u);
      if (cs != null) {
        ref = '${cs.group(1)} ${int.parse(cs.group(2)!)}';
        kill(cs.start, cs.end);
      }
    }

    String? toneHint;
    final tone = RegExp(
      r'\b(\d+)\s*TO(?:M|NS)\s*(ABAIXO|ACIMA)(?:\s+([A-G][#B]?M?))?\b',
    ).firstMatch(u);
    if (tone != null) {
      final dir = tone.group(2) == 'ABAIXO' ? 'abaixo' : 'acima';
      final key = tone.group(3);
      toneHint =
          '${tone.group(1)} tom $dir${key != null ? ' (${key[0]}${key.substring(1).toLowerCase()})' : ''}';
      kill(tone.start, tone.end);
    }

    final kinds = <String>[];
    String? status;
    for (final (regex, label, isStatus) in _tags) {
      for (final m in regex.allMatches(u)) {
        if (!free(m.start, m.end)) continue;
        kill(m.start, m.end);
        if (isStatus) {
          status = label;
        } else if (!kinds.contains(label)) {
          kinds.add(label);
        }
      }
    }

    for (final m in RegExp(r'\bHINO\b').allMatches(u)) {
      kill(m.start, m.end);
    }

    var name = mask.map((c) => c == '\u0000' ? ' ' : c).join();
    name = name.replaceAll(RegExp(r'\s+'), ' ').trim();
    name = name.replaceAll(RegExp(r'^[\s\-–—:]+|[\s\-–—:]+$'), '');
    name = name
        .replaceAll(RegExp(r'\(\s+'), '(')
        .replaceAll(RegExp(r'\s+\)'), ')');

    if (ref == null) {
      final trailing = RegExp(r'\s(\d{1,4})$').firstMatch(name);
      if (trailing != null) {
        ref = trailing.group(1);
        name = name.substring(0, trailing.start).trim();
      }
    }

    name = _prettyCase(name);

    return CifraTitle._(
      original: title,
      name: name.isEmpty ? title.trim() : name,
      seq: seq,
      hymnRef: ref,
      kinds: kinds,
      toneHint: toneHint,
      status: status,
    );
  }

  /// Palavras TODAS MAIÚSCULAS viram "Capitalizadas"; o resto fica igual.
  static String _prettyCase(String name) {
    final words = name.split(' ');
    final out = <String>[];
    for (var i = 0; i < words.length; i++) {
      var w = words[i];
      final core = w.replaceAll(RegExp(r'[()]'), '');
      final letters = core.split('').where(_isLetter).toList();
      final allUpper =
          letters.isNotEmpty && letters.every((c) => c == c.toUpperCase());
      if (allUpper) {
        final low = w.toLowerCase();
        if (i > 0 && _small.contains(core.toLowerCase()) && !w.startsWith('(')) {
          w = low;
        } else {
          final j = low.split('').indexWhere(_isLetter);
          w = j < 0
              ? low
              : low.substring(0, j) +
                    low[j].toUpperCase() +
                    low.substring(j + 1);
        }
      } else if (i == 0 && w.isNotEmpty) {
        w = w[0].toUpperCase() + w.substring(1);
      }
      out.add(w);
    }
    return out.join(' ');
  }

  static bool _isLetter(String c) => c.toLowerCase() != c.toUpperCase();

  // ---------------------------------------------------------------------------
  // Normalização para busca
  // ---------------------------------------------------------------------------

  static const _accents = 'áàãâäéèêëíìîïóòõôöúùûüçñÁÀÃÂÄÉÈÊËÍÌÎÏÓÒÕÔÖÚÙÛÜÇÑ';
  static const _plain = 'aaaaaeeeeiiiiooooouuuucnAAAAAEEEEIIIIOOOOOUUUUCN';

  /// Remove acentos trocando 1 caractere por 1 (mantém os índices).
  static String stripAccentsSameLength(String text) {
    final buffer = StringBuffer();
    for (final c in text.split('')) {
      final i = _accents.indexOf(c);
      buffer.write(i >= 0 ? _plain[i] : c);
    }
    return buffer.toString();
  }

  /// "Hino C-73 Graça!" -> "hino c73 graca"
  static String normalize(String text) {
    var t = stripAccentsSameLength(text).toLowerCase();
    t = t.replaceAll(RegExp(r'[^a-z0-9]+'), ' ');
    // "c 73", "c-073", "s19" viram "c73" / "s19"
    t = t.replaceAllMapped(
      RegExp(r'\b([cs])\s*0*(\d{1,3})\b'),
      (m) => '${m.group(1)}${m.group(2)}',
    );
    return t.replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}

/// Busca por palavras: todas as palavras digitadas precisam aparecer
/// (no começo de alguma palavra do título), em qualquer ordem.
class CifraSearch {
  static List<String> tokens(String query) => CifraTitle.normalize(
    query,
  ).split(' ').where((t) => t.isNotEmpty).toList();

  /// Pontuação (0 = não bate). Quanto maior, mais relevante.
  static int score(String title, List<String> queryTokens) {
    if (queryTokens.isEmpty) return 1;
    final parsed = CifraTitle.parse(title);
    final nameTokens = CifraTitle.normalize(parsed.name).split(' ');
    final allTokens = CifraTitle.normalize(title).split(' ');
    final ref = parsed.hymnRef == null
        ? null
        : CifraTitle.normalize(parsed.hymnRef!);

    var total = 0;
    for (final q in queryTokens) {
      var best = 0;
      if (ref != null && ref == q) best = 30;
      // "73" também acha "C 73"
      if (ref != null && best == 0 && ref.replaceAll(RegExp(r'[^0-9]'), '') == q) {
        best = 20;
      }
      if (parsed.seq == q) best = best < 25 ? 25 : best;
      for (final t in nameTokens) {
        if (t == q) {
          best = best < 12 ? 12 : best;
        } else if (t.startsWith(q)) {
          best = best < 8 ? 8 : best;
        } else if (q.length >= 4 && t.contains(q)) {
          best = best < 4 ? 4 : best;
        }
      }
      if (best == 0) {
        for (final t in allTokens) {
          if (t.startsWith(q)) {
            best = 3;
            break;
          }
        }
      }
      if (best == 0) return 0; // essa palavra não aparece: fora
      total += best;
    }
    if (parsed.isCorrected) total += 2;
    return total;
  }
}
