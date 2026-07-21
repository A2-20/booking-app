import 'package:flutter/foundation.dart';
import '../services/favorites_service.dart';

class FavoritesState extends ChangeNotifier {
  final Set<String> _favoriteIds = {};
  final Map<String, int> _favoriteCounts = {};
  bool _isLoading = false;
  bool _initialized = false;

  bool get isLoading => _isLoading;
  bool get initialized => _initialized;

  /// Returns true if the given hotel is favorited by the current user.
  bool isFavorite(String hotelId) => _favoriteIds.contains(hotelId);

  /// Returns the total number of favorites (all users) for a hotel.
  int getFavoritesCount(String hotelId) => _favoriteCounts[hotelId] ?? 0;

  /// Returns the total number of hotels the current user has favorited.
  int get totalUserFavorites => _favoriteIds.length;

  /// Returns all favorited hotel IDs.
  Set<String> get favoriteIds => Set.unmodifiable(_favoriteIds);

  /// Returns hotel ID with the most favorites count.
  String? get mostLikedHotelId {
    if (_favoriteCounts.isEmpty) return null;
    return _favoriteCounts.entries
        .reduce((a, b) => a.value >= b.value ? a : b)
        .key;
  }

  /// Updates the favorites count for a specific hotel.
  void updateCount(String hotelId, int count) {
    _favoriteCounts[hotelId] = count;
    notifyListeners();
  }

  /// Bulk-seeds favorites counts from the hotel listing (from API).
  void seedCounts(Map<String, int> counts) {
    _favoriteCounts.addAll(counts);
    notifyListeners();
  }

  /// Loads the current user's favorited hotel IDs from the API.
  Future<void> loadFavorites() async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      final ids = await FavoritesService.getFavoriteIds();
      _favoriteIds
        ..clear()
        ..addAll(ids);
      _initialized = true;
    } catch (e) {
      print('loadFavorites error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Toggles the favorite status for a hotel with optimistic UI update.
  Future<void> toggleFavorite(String hotelId) async {
    // Optimistic update
    final wasAlreadyFavorite = _favoriteIds.contains(hotelId);
    if (wasAlreadyFavorite) {
      _favoriteIds.remove(hotelId);
      final currentCount = _favoriteCounts[hotelId] ?? 0;
      if (currentCount > 0) {
        _favoriteCounts[hotelId] = currentCount - 1;
      }
    } else {
      _favoriteIds.add(hotelId);
      _favoriteCounts[hotelId] = (_favoriteCounts[hotelId] ?? 0) + 1;
    }
    notifyListeners();

    // API call
    final result = await FavoritesService.toggleFavorite(hotelId);
    if (result != null) {
      final isFav = result['is_favorite'] as bool;
      final count = result['favorites_count'] as int;

      if (isFav) {
        _favoriteIds.add(hotelId);
      } else {
        _favoriteIds.remove(hotelId);
      }
      _favoriteCounts[hotelId] = count;
    } else {
      // Revert optimistic change if API failed
      if (wasAlreadyFavorite) {
        _favoriteIds.add(hotelId);
        _favoriteCounts[hotelId] = (_favoriteCounts[hotelId] ?? 0) + 1;
      } else {
        _favoriteIds.remove(hotelId);
        final currentCount = _favoriteCounts[hotelId] ?? 0;
        if (currentCount > 0) {
          _favoriteCounts[hotelId] = currentCount - 1;
        }
      }
    }
    notifyListeners();
  }

  /// Clears favorites on logout.
  void clear() {
    _favoriteIds.clear();
    _initialized = false;
    notifyListeners();
  }
}
