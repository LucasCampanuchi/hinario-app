import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:mobx/mobx.dart';

import '../../../../../api/connection/app_api.dart';
import '../../../../../models/cifra.dart';
import '../../../../../services/cifra_lookup_service.dart';
import '../../../../../services/community_cifra_service.dart';
import '../../../../../utils/cifra_title.dart';
import '../../../../playlists/views/playlists_page.dart';
import '../../new_cifra/new_cifra_flow.dart';
import '../store/cifras.store.dart';
import '../widgets/cifra_card.dart' show showAddCifraToPlaylist;

const _primary = Color(0xFF3E5A86);
const _community = Color(0xFF7C3AED);
const _ok = Color(0xFF16A34A);

enum _Filter { all, cifra, sax, community }

class CifrasPage extends StatefulWidget {
  const CifrasPage({Key? key}) : super(key: key);

  @override
  State<CifrasPage> createState() => _CifrasPageState();
}

class _CifrasPageState extends State<CifrasPage> {
  /// Continua cuidando da sincronização (contadores, progresso, avisos).
  final CifrasStore store = CifrasStore();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scroll = ScrollController();

  List<Cifra> _all = [];
  Set<int> _mine = {};
  bool _loading = true;
  String _query = '';
  _Filter _filter = _Filter.all;
  Timer? _debounce;
  ReactionDisposer? _syncReaction;

  @override
  void initState() {
    super.initState();
    store.loadCifras(); // contadores + checagem de novas cifras na API
    _reload();
    // Quando a sincronização termina, recarrega a lista
    _syncReaction = reaction<bool>(
      (_) => store.syncProgress.isSyncing,
      (syncing) {
        if (!syncing) _reload();
      },
    );
  }

  @override
  void dispose() {
    _syncReaction?.call();
    _debounce?.cancel();
    _searchController.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    final map = await CifraLookupService.instance.all(refresh: true);
    final mine = await CommunityCifraService.instance.mineIds();
    if (!mounted) return;
    setState(() {
      _all = map.values.toList()..sort((a, b) => b.id.compareTo(a.id));
      _mine = mine;
      _loading = false;
    });
  }

  void _onSearch(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 180), () {
      if (mounted) setState(() => _query = value);
    });
  }

  bool _passesFilter(Cifra c, CifraTitle t) => switch (_filter) {
    _Filter.all => true,
    _Filter.cifra => !t.isSax,
    _Filter.sax => t.isSax,
    _Filter.community => c.isCommunity,
  };

  List<Cifra> get _visible {
    final tokens = CifraSearch.tokens(_query);
    final scored = <(Cifra, int)>[];
    for (final c in _all) {
      final t = CifraTitle.parse(c.title);
      if (!_passesFilter(c, t)) continue;
      final score = CifraSearch.score(c.title, tokens);
      if (score > 0) scored.add((c, score));
    }
    if (tokens.isNotEmpty) {
      scored.sort((a, b) {
        final byScore = b.$2.compareTo(a.$2);
        return byScore != 0 ? byScore : b.$1.id.compareTo(a.$1.id);
      });
    }
    return scored.map((e) => e.$1).toList();
  }

  /// Chave "mesmo hino, mesmo instrumento" para marcar versões antigas.
  String _groupKey(CifraTitle t) =>
      '${CifraTitle.normalize(t.name)}|${t.kinds.join(',')}';

  @override
  Widget build(BuildContext context) {
    final visible = _visible;
    final correctedGroups = <String>{
      for (final c in _all)
        if (CifraTitle.parse(c.title).isCorrected)
          _groupKey(CifraTitle.parse(c.title)),
    };

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Cifras',
              style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
            ),
            if (_all.isNotEmpty)
              Text(
                '${_all.length} no aparelho',
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Playlists e Ao vivo',
            icon: const Icon(Icons.queue_music_rounded, color: Colors.white),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PlaylistsPage()),
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'sync') store.syncCifras();
              if (value == 'clear') _confirmClear();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'sync', child: Text('Sincronizar agora')),
              PopupMenuDivider(),
              PopupMenuItem(
                value: 'clear',
                child: Text('Apagar todas do aparelho', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        onPressed: _newCifra,
        icon: const Icon(Icons.add_a_photo_outlined),
        label: const Text('Nova cifra'),
      ),
      body: Column(
        children: [
          _header(),
          _syncBanners(),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _all.isEmpty
                ? _emptyLibrary()
                : visible.isEmpty
                ? _noResults()
                : RefreshIndicator(
                    onRefresh: () async {
                      store.syncCifras();
                      await _reload();
                    },
                    child: ListView.builder(
                      controller: _scroll,
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 96),
                      itemCount: visible.length,
                      itemBuilder: (context, index) {
                        final cifra = visible[index];
                        final t = CifraTitle.parse(cifra.title);
                        final outdated = !t.isCorrected &&
                            correctedGroups.contains(_groupKey(t));
                        return _CifraTile(
                          cifra: cifra,
                          title: t,
                          outdated: outdated,
                          isMine: _mine.contains(cifra.id),
                          onOpen: () => _open(cifra),
                          onMenu: (action) => _onMenu(action, cifra),
                        );
                      },
                    ),
                  ),
          ),
          _syncProgress(),
        ],
      ),
    );
  }

  Widget _header() {
    final communityCount = _all.where((c) => c.isCommunity).length;

    return Container(
      color: _primary,
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: _onSearch,
            textInputAction: TextInputAction.search,
            style: const TextStyle(fontSize: 16),
            decoration: InputDecoration(
              hintText: 'Nome, número do hino (321, C 73)...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                    ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _chip(_Filter.all, 'Tudo'),
                _chip(_Filter.cifra, 'Cifras'),
                _chip(_Filter.sax, 'Sax'),
                if (communityCount > 0)
                  _chip(_Filter.community, 'Enviadas ($communityCount)'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(_Filter f, String label) {
    final selected = _filter == f;
    // Pílula própria (o ChoiceChip do Material 3 pintava o fundo de branco
    // e o texto branco sumia).
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: selected ? Colors.white : Colors.white.withValues(alpha: 0.16),
        shape: StadiumBorder(
          side: BorderSide(
            color: selected ? Colors.white : Colors.white.withValues(alpha: 0.35),
          ),
        ),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: () => setState(() => _filter = f),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              label,
              style: TextStyle(
                color: selected ? _primary : Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _syncBanners() {
    return Observer(
      builder: (_) {
        if (store.syncProgress.isSyncing) return const SizedBox.shrink();
        if (store.isStartingSync) {
          return _banner(
            icon: const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            text: 'Iniciando sincronização...',
            color: _primary,
          );
        }
        if (store.errorMessage != null) {
          return _banner(
            icon: const Icon(Icons.cloud_off_rounded, color: Colors.red),
            text: 'Não foi possível sincronizar agora',
            color: Colors.red.shade700,
            action: 'Tentar de novo',
            onAction: store.syncCifras,
          );
        }
        if (store.needsUpdate) {
          return _banner(
            icon: const Icon(Icons.cloud_download_outlined, color: _primary),
            text: store.missingCifras == 1
                ? '1 cifra nova para baixar'
                : '${store.missingCifras} cifras novas para baixar',
            color: _primary,
            action: 'Baixar',
            onAction: store.syncCifras,
          );
        }
        if (store.hasFileIssues) {
          return _banner(
            icon: const Icon(Icons.warning_amber_rounded, color: Colors.orange),
            text: 'Alguns arquivos estão faltando no aparelho',
            color: Colors.orange.shade800,
            action: 'Reparar',
            onAction: store.syncCifras,
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _banner({
    required Widget icon,
    required String text,
    required Color color,
    String? action,
    VoidCallback? onAction,
  }) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      padding: const EdgeInsets.fromLTRB(12, 6, 6, 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          icon,
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
            ),
          ),
          if (action != null)
            TextButton(onPressed: onAction, child: Text(action)),
        ],
      ),
    );
  }

  Widget _syncProgress() {
    return Observer(
      builder: (_) {
        final p = store.syncProgress;
        if (!p.isSyncing) return const SizedBox.shrink();
        return Material(
          elevation: 8,
          color: Colors.white,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Baixando cifras: ${p.current}/${p.total} (${p.progressPercent}%)',
                    style: const TextStyle(fontWeight: FontWeight.w600, color: _primary),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: p.progress,
                      minHeight: 6,
                      color: _primary,
                      backgroundColor: _primary.withValues(alpha: 0.15),
                    ),
                  ),
                  if (p.currentItem.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      CifraTitle.parse(p.currentItem).name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _emptyLibrary() {
    return ListView(
      children: [
        const SizedBox(height: 80),
        const Icon(Icons.library_music_outlined, size: 64, color: _primary),
        const SizedBox(height: 16),
        const Text(
          'Nenhuma cifra no aparelho ainda',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          'Baixe as cifras uma vez e elas funcionam sem internet.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade600),
        ),
        const SizedBox(height: 20),
        Center(
          child: FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: _primary),
            onPressed: store.syncCifras,
            icon: const Icon(Icons.cloud_download_outlined),
            label: const Text('Baixar cifras'),
          ),
        ),
      ],
    );
  }

  Widget _noResults() {
    return ListView(
      padding: const EdgeInsets.all(32),
      children: [
        const SizedBox(height: 40),
        Icon(Icons.search_off_rounded, size: 56, color: Colors.grey.shade400),
        const SizedBox(height: 12),
        Text(
          _query.isEmpty
              ? 'Nada neste filtro.'
              : 'Nenhuma cifra para "$_query".',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        Text(
          'Não achou? Mande uma foto ou digite a cifra para todo mundo.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade600),
        ),
        const SizedBox(height: 16),
        Center(
          child: OutlinedButton.icon(
            onPressed: () => _newCifra(suggested: _query),
            icon: const Icon(Icons.add_a_photo_outlined),
            label: const Text('Adicionar esta cifra'),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------

  void _open(Cifra cifra) {
    if (cifra.localFilePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Esta cifra ainda não foi baixada.'),
          action: SnackBarAction(label: 'Baixar', onPressed: store.syncCifras),
        ),
      );
      return;
    }
    Modular.to.pushNamed('/cifra_view', arguments: {'cifra': cifra});
  }

  Future<void> _newCifra({String? suggested}) async {
    final created = await startNewCifra(
      context,
      suggestedTitle: suggested?.trim().isEmpty == true ? null : suggested,
    );
    if (created == null || !mounted) return;
    await _reload();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${CifraTitle.parse(created.title).name}" enviada para a igreja'),
        action: SnackBarAction(label: 'Abrir', onPressed: () => _open(created)),
      ),
    );
  }

  Future<void> _onMenu(String action, Cifra cifra) async {
    switch (action) {
      case 'playlist':
        showAddCifraToPlaylist(context, cifra);
      case 'edit':
        if (cifra.kind != 'text' || cifra.localFilePath == null) return;
        final content = await File(cifra.localFilePath!).readAsString();
        if (!mounted) return;
        final updated = await Navigator.of(context).push<Cifra>(
          MaterialPageRoute(
            builder: (_) => TextCifraEditorPage(
              editing: cifra,
              initialContent: content,
            ),
          ),
        );
        if (updated != null) await _reload();
      case 'delete':
        final ok = await showDialog<bool>(
          context: context,
          builder: (c) => AlertDialog(
            title: const Text('Apagar cifra?'),
            content: const Text('Ela some para todos da igreja.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancelar')),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.pop(c, true),
                child: const Text('Apagar'),
              ),
            ],
          ),
        );
        if (ok != true) return;
        try {
          await CommunityCifraService.instance.delete(cifra);
          await _reload();
        } on ApiException catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(e.message), backgroundColor: Colors.red),
            );
          }
        }
      case 'title':
        showDialog<void>(
          context: context,
          builder: (c) => AlertDialog(
            title: const Text('Título original'),
            content: SelectableText(cifra.title),
            actions: [
              TextButton(onPressed: () => Navigator.pop(c), child: const Text('Fechar')),
            ],
          ),
        );
    }
  }

  void _confirmClear() {
    showDialog<void>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Apagar todas as cifras do aparelho?'),
        content: const Text('Você pode baixar de novo depois em Sincronizar.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              Navigator.pop(c);
              await store.clearAllCifras();
              await _reload();
            },
            child: const Text('Apagar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------

class _CifraTile extends StatelessWidget {
  final Cifra cifra;
  final CifraTitle title;
  final bool outdated;
  final bool isMine;
  final VoidCallback onOpen;
  final void Function(String action) onMenu;

  const _CifraTile({
    required this.cifra,
    required this.title,
    required this.outdated,
    required this.isMine,
    required this.onOpen,
    required this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    final accent = cifra.isCommunity ? _community : _primary;
    final downloaded = cifra.localFilePath != null;

    return Opacity(
      opacity: downloaded ? (outdated ? 0.6 : 1.0) : 0.55,
      child: Card(
        elevation: 0,
        color: Colors.white,
        margin: const EdgeInsets.only(bottom: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onOpen,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Badge(title: title, cifra: cifra, color: accent),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title.name,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.2,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          for (final c in title.chips) _tag(c, Colors.grey.shade700),
                          if (title.isCorrected)
                            _tag(title.status!, _ok, icon: Icons.verified_rounded),
                          if (outdated) _tag('Versão anterior', Colors.grey.shade600),
                          if (cifra.kind == 'image') _tag('Foto', _community, icon: Icons.photo_outlined),
                          if (cifra.kind == 'text') _tag('Texto', _community, icon: Icons.notes_rounded),
                          if (cifra.tone != null) _tag('Tom ${cifra.tone}', Colors.orange.shade800),
                          if (cifra.isCommunity)
                            _tag(isMine ? 'por você' : 'por ${cifra.authorName}', _community),
                          if (!downloaded) _tag('Não baixada', Colors.red.shade400, icon: Icons.cloud_off),
                          if (title.seq != null)
                            Text(
                              'nº ${title.seq}',
                              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: Colors.grey.shade500),
                  onSelected: onMenu,
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'playlist', child: Text('Adicionar à playlist')),
                    const PopupMenuItem(value: 'title', child: Text('Ver título original')),
                    if (isMine && cifra.kind == 'text')
                      const PopupMenuItem(value: 'edit', child: Text('Editar cifra')),
                    if (isMine)
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Apagar', style: TextStyle(color: Colors.red)),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _tag(String text, Color color, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 3),
          ],
          Text(
            text,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final CifraTitle title;
  final Cifra cifra;
  final Color color;

  const _Badge({required this.title, required this.cifra, required this.color});

  @override
  Widget build(BuildContext context) {
    final ref = title.hymnRef;
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: ref != null
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'HINO',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: color.withValues(alpha: 0.7),
                  ),
                ),
                FittedBox(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      ref,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                  ),
                ),
              ],
            )
          : Icon(
              cifra.kind == 'image'
                  ? Icons.photo_outlined
                  : cifra.kind == 'text'
                  ? Icons.notes_rounded
                  : title.isSax
                  ? Icons.music_note_rounded
                  : Icons.queue_music_rounded,
              color: color,
            ),
    );
  }
}
