import '../models/hotel_model.dart';
import 'api_service.dart';

class HotelService {
  // Get all hotels
  static Future<List<HotelModel>> getAllHotels() async {
    try {
      final response = await ApiService.get('/hotels');
      if (response.statusCode == 200) {
        return (response.data as List)
            .map((json) => HotelModel.fromJson(json))
            .toList();
      }
    } catch (e) {
      print('Fetch hotels error: $e');
    }
    return [];
  }

  // Get hotel by ID
  static Future<HotelModel?> getHotelById(String hotelId) async {
    final hotels = await getAllHotels();
    try {
      return hotels.firstWhere((h) => h.hotelId == hotelId);
    } catch (e) {
      return null;
    }
  }

  // Initialize hotels
  static Future<void> initializeHotels() async {
    await getAllHotels();
  }

  // Search hotels
  static Future<List<HotelModel>> searchHotels({
    String? query,
    String? city,
  }) async {
    final hotels = await getAllHotels();
    final q = (query ?? city ?? '').toLowerCase();
    if (q.isEmpty) return hotels;

    return hotels
        .where(
          (h) =>
              h.nameAr.toLowerCase().contains(q) ||
              h.nameEn.toLowerCase().contains(q) ||
              h.cityAr.toLowerCase().contains(q) ||
              h.cityEn.toLowerCase().contains(q),
        )
        .toList();
  }
}
