import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteEntry {
  final String id;
  final String title;
  final String? image;
  final double? score;
  final int? episodes;
  final int addedAt;

  FavoriteEntry({
    required this.id,
    required this.title,
    this.image,
    this.score,
    this.episodes,
    required this.addedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'image': image,
        'score': score,
        'episodes': episodes,
        'addedAt': addedAt,
      };

  factory FavoriteEntry.fromJson(Map<String, dynamic> json) => FavoriteEntry(
        id: json['id'] as String,
        title: json['title'] as String,
        image: json['image'] as String?,
        score: (json['score'] as num?)?.toDouble(),
        episodes: json['episodes'] as int?,
        addedAt: json['addedAt'] as int,
      );
}

class WatchHistoryEntry {
  final String animeId;
  final String animeTitle;
  final String? animeImage;
  final String episodeId;
  final double episodeNumber;
  final String? episodeTitle;
  final Duration progress;
  final Duration? duration;
  final int watchedAt;

  WatchHistoryEntry({
    required this.animeId,
    required this.animeTitle,
    this.animeImage,
    required this.episodeId,
    required this.episodeNumber,
    this.episodeTitle,
    required this.progress,
    this.duration,
    required this.watchedAt,
  });

  Map<String, dynamic> toJson() => {
        'animeId': animeId,
        'animeTitle': animeTitle,
        'animeImage': animeImage,
        'episodeId': episodeId,
        'episodeNumber': episodeNumber,
        'episodeTitle': episodeTitle,
        'progressMs': progress.inMilliseconds,
        'durationMs': duration?.inMilliseconds,
        'watchedAt': watchedAt,
      };

  factory WatchHistoryEntry.fromJson(Map<String, dynamic> json) =>
      WatchHistoryEntry(
        animeId: json['animeId'] as String,
        animeTitle: json['animeTitle'] as String,
        animeImage: json['animeImage'] as String?,
        episodeId: json['episodeId'] as String,
        episodeNumber: (json['episodeNumber'] as num).toDouble(),
        episodeTitle: json['episodeTitle'] as String?,
        progress: Duration(milliseconds: (json['progressMs'] as num).toInt()),
        duration: json['durationMs'] != null
            ? Duration(milliseconds: (json['durationMs'] as num).toInt())
            : null,
        watchedAt: json['watchedAt'] as int,
      );

  bool get isCompleted =>
      duration != null && progress >= duration! * 0.9;
}

class StorageService {
  static const _favoritesKey = 'favorites';
  static const _watchHistoryKey = 'watch_history';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  List<FavoriteEntry> getFavorites() {
    final raw = _prefs.getString(_favoritesKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => FavoriteEntry.fromJson(e as Map<String, dynamic>)).toList();
  }

  void addFavorite(FavoriteEntry entry) {
    final favorites = getFavorites();
    favorites.removeWhere((f) => f.id == entry.id);
    favorites.insert(0, entry);
    _prefs.setString(_favoritesKey, jsonEncode(favorites.map((f) => f.toJson()).toList()));
  }

  void removeFavorite(String id) {
    final favorites = getFavorites();
    favorites.removeWhere((f) => f.id == id);
    _prefs.setString(_favoritesKey, jsonEncode(favorites.map((f) => f.toJson()).toList()));
  }

  bool isFavorite(String id) {
    return getFavorites().any((f) => f.id == id);
  }

  List<WatchHistoryEntry> getWatchHistory() {
    final raw = _prefs.getString(_watchHistoryKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => WatchHistoryEntry.fromJson(e as Map<String, dynamic>)).toList();
  }

  void addToHistory(WatchHistoryEntry entry) {
    final history = getWatchHistory();
    history.removeWhere((h) => h.episodeId == entry.episodeId);
    history.insert(0, entry);
    _prefs.setString(_watchHistoryKey, jsonEncode(history.map((h) => h.toJson()).toList()));
  }

  List<WatchHistoryEntry> getContinueWatching() {
    final history = getWatchHistory();
    final seen = <String>{};
    final result = <WatchHistoryEntry>[];
    for (final entry in history) {
      if (!seen.contains(entry.animeId)) {
        seen.add(entry.animeId);
        result.add(entry);
      }
    }
    return result;
  }

  WatchHistoryEntry? getLastWatchForAnime(String animeId) {
    return getWatchHistory().where((h) => h.animeId == animeId).firstOrNull;
  }

  String getString(String key, String defaultValue) {
    return _prefs.getString(key) ?? defaultValue;
  }

  void setString(String key, String value) {
    _prefs.setString(key, value);
  }
}

final sharedPrefsProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Must be overridden in main()');
});

final storageServiceProvider = Provider<StorageService>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return StorageService(prefs);
});

final favoritesProvider =
    NotifierProvider<FavoritesNotifier, List<FavoriteEntry>>(
  FavoritesNotifier.new,
);

class FavoritesNotifier extends Notifier<List<FavoriteEntry>> {
  @override
  List<FavoriteEntry> build() {
    final storage = ref.watch(storageServiceProvider);
    return storage.getFavorites();
  }

  void toggle(FavoriteEntry entry) {
    final storage = ref.read(storageServiceProvider);
    if (storage.isFavorite(entry.id)) {
      storage.removeFavorite(entry.id);
      state = storage.getFavorites();
    } else {
      storage.addFavorite(entry);
      state = storage.getFavorites();
    }
  }

  bool isFavorite(String id) {
    return ref.read(storageServiceProvider).isFavorite(id);
  }
}

final watchHistoryProvider =
    NotifierProvider<WatchHistoryNotifier, List<WatchHistoryEntry>>(
  WatchHistoryNotifier.new,
);

class WatchHistoryNotifier extends Notifier<List<WatchHistoryEntry>> {
  @override
  List<WatchHistoryEntry> build() {
    final storage = ref.watch(storageServiceProvider);
    return storage.getWatchHistory();
  }

  void add(WatchHistoryEntry entry) {
    final storage = ref.read(storageServiceProvider);
    storage.addToHistory(entry);
    state = storage.getWatchHistory();
  }

  List<WatchHistoryEntry> getContinueWatching() {
    return ref.read(storageServiceProvider).getContinueWatching();
  }
}
