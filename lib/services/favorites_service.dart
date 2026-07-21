import 'api_service.dart';

class FavoritesService {
  /// Returns list of favorite hotel IDs for the current user.
  static Future<List<String>> getFavoriteIds() async {
    try {
      final response = await ApiService.get('/hotels/favorites');
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          return data.map((e) => e.toString()).toList();
        }
        if (data is Map && data['data'] is List) {
          return (data['data'] as List).map((e) => e.toString()).toList();
        }
      }
    } catch (e) {
      print('getFavoriteIds error: $e');
    }
    return [];
  }

  /// Toggle favorite for a hotel. Returns a map with:
  ///   { 'is_favorite': bool, 'favorites_count': int }
  static Future<Map<String, dynamic>?> toggleFavorite(String hotelId) async {
    try {
      final response = await ApiService.post('/hotels/$hotelId/favorite');
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          return {
            'is_favorite': data['is_favorite'] as bool? ?? false,
            'favorites_count': (data['favorites_count'] as num?)?.toInt() ?? 0,
          };
        }
      }
    } catch (e) {
      print('toggleFavorite error: $e');
    }
    return null;
  }

  /// Returns favorite counts for all hotels as a map { hotelId: count }.
  static Future<Map<String, int>> getFavoriteCounts() async {
    try {
      final response = await ApiService.get('/hotels/favorites/counts');
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map) {
          return data.map((k, v) => MapEntry(k.toString(), (v as num).toInt()));
        }
      }
    } catch (e) {
      print('getFavoriteCounts error: $e');
    }
    return {};
  }
}
