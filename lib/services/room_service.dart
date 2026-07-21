import '../models/room_model.dart';
import 'api_service.dart';

class RoomService {
  // Get rooms by hotel ID from API
  static Future<List<RoomModel>> getRoomsByHotelId(String hotelId) async {
    try {
      final response = await ApiService.get('/hotels/$hotelId/rooms');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => RoomModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Fetch rooms error: $e');
      return [];
    }
  }

  // Get room by ID (can be implemented if needed, but usually rooms are fetched per hotel)
  static Future<RoomModel?> getRoomById(String hotelId, String roomId) async {
    final rooms = await getRoomsByHotelId(hotelId);
    try {
      return rooms.firstWhere((r) => r.roomId == roomId);
    } catch (e) {
      return null;
    }
  }
}
