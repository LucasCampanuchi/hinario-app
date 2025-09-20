// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playlist.store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$PlaylistStore on _PlaylistStoreBase, Store {
  Computed<int>? _$totalPlaylistsComputed;

  @override
  int get totalPlaylists =>
      (_$totalPlaylistsComputed ??= Computed<int>(() => super.totalPlaylists,
              name: '_PlaylistStoreBase.totalPlaylists'))
          .value;
  Computed<List<Playlist>>? _$sortedPlaylistsComputed;

  @override
  List<Playlist> get sortedPlaylists => (_$sortedPlaylistsComputed ??=
          Computed<List<Playlist>>(() => super.sortedPlaylists,
              name: '_PlaylistStoreBase.sortedPlaylists'))
      .value;

  late final _$playlistsAtom =
      Atom(name: '_PlaylistStoreBase.playlists', context: context);

  @override
  ObservableList<Playlist> get playlists {
    _$playlistsAtom.reportRead();
    return super.playlists;
  }

  @override
  set playlists(ObservableList<Playlist> value) {
    _$playlistsAtom.reportWrite(value, super.playlists, () {
      super.playlists = value;
    });
  }

  late final _$isLoadingAtom =
      Atom(name: '_PlaylistStoreBase.isLoading', context: context);

  @override
  bool get isLoading {
    _$isLoadingAtom.reportRead();
    return super.isLoading;
  }

  @override
  set isLoading(bool value) {
    _$isLoadingAtom.reportWrite(value, super.isLoading, () {
      super.isLoading = value;
    });
  }

  late final _$errorMessageAtom =
      Atom(name: '_PlaylistStoreBase.errorMessage', context: context);

  @override
  String? get errorMessage {
    _$errorMessageAtom.reportRead();
    return super.errorMessage;
  }

  @override
  set errorMessage(String? value) {
    _$errorMessageAtom.reportWrite(value, super.errorMessage, () {
      super.errorMessage = value;
    });
  }

  late final _$loadPlaylistsAsyncAction =
      AsyncAction('_PlaylistStoreBase.loadPlaylists', context: context);

  @override
  Future<void> loadPlaylists() {
    return _$loadPlaylistsAsyncAction.run(() => super.loadPlaylists());
  }

  late final _$createPlaylistAsyncAction =
      AsyncAction('_PlaylistStoreBase.createPlaylist', context: context);

  @override
  Future<bool> createPlaylist(
      {required String title,
      String description = '',
      List<int> cifraIds = const []}) {
    return _$createPlaylistAsyncAction.run(() => super.createPlaylist(
        title: title, description: description, cifraIds: cifraIds));
  }

  late final _$updatePlaylistAsyncAction =
      AsyncAction('_PlaylistStoreBase.updatePlaylist', context: context);

  @override
  Future<bool> updatePlaylist(Playlist playlist) {
    return _$updatePlaylistAsyncAction
        .run(() => super.updatePlaylist(playlist));
  }

  late final _$deletePlaylistAsyncAction =
      AsyncAction('_PlaylistStoreBase.deletePlaylist', context: context);

  @override
  Future<bool> deletePlaylist(String playlistId) {
    return _$deletePlaylistAsyncAction
        .run(() => super.deletePlaylist(playlistId));
  }

  late final _$addCifraToPlaylistAsyncAction =
      AsyncAction('_PlaylistStoreBase.addCifraToPlaylist', context: context);

  @override
  Future<bool> addCifraToPlaylist(String playlistId, int cifraId) {
    return _$addCifraToPlaylistAsyncAction
        .run(() => super.addCifraToPlaylist(playlistId, cifraId));
  }

  late final _$removeCifraFromPlaylistAsyncAction = AsyncAction(
      '_PlaylistStoreBase.removeCifraFromPlaylist',
      context: context);

  @override
  Future<bool> removeCifraFromPlaylist(String playlistId, int cifraId) {
    return _$removeCifraFromPlaylistAsyncAction
        .run(() => super.removeCifraFromPlaylist(playlistId, cifraId));
  }

  late final _$_PlaylistStoreBaseActionController =
      ActionController(name: '_PlaylistStoreBase', context: context);

  @override
  void clearError() {
    final _$actionInfo = _$_PlaylistStoreBaseActionController.startAction(
        name: '_PlaylistStoreBase.clearError');
    try {
      return super.clearError();
    } finally {
      _$_PlaylistStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
playlists: ${playlists},
isLoading: ${isLoading},
errorMessage: ${errorMessage},
totalPlaylists: ${totalPlaylists},
sortedPlaylists: ${sortedPlaylists}
    ''';
  }
}
