import '../models/flight_model.dart';
import 'api_service.dart';

class FlightService {
  // Get all flights
  static Future<List<FlightModel>> getAllFlights() async {
    try {
      final response = await ApiService.get('/flights');
      if (response.statusCode == 200) {
        return (response.data as List)
            .map((json) => FlightModel.fromJson(json))
            .toList();
      }
    } catch (e) {
      print('Fetch flights error: $e');
    }
    return [];
  }

  // Get flight by ID
  static Future<FlightModel?> getFlightById(String flightId) async {
    final flights = await getAllFlights();
    try {
      return flights.firstWhere((f) => f.flightId == flightId);
    } catch (e) {
      return null;
    }
  }

  // Initialize flights (placeholder or data loading logic)
  static Future<void> initializeFlights() async {
    // Logic to initialize or pre-fetch flights if needed
    await getAllFlights();
  }

  // Search flights
  static Future<List<FlightModel>> searchFlights({
    String? departureCity,
    String? arrivalCity,
  }) async {
    final flights = await getAllFlights();
    return flights.where((f) {
      bool matches = true;
      if (departureCity != null && departureCity.isNotEmpty) {
        final q = departureCity.toLowerCase();
        matches =
            matches &&
            (f.departureCityAr.toLowerCase().contains(q) ||
                f.departureCityEn.toLowerCase().contains(q));
      }
      if (arrivalCity != null && arrivalCity.isNotEmpty) {
        final q = arrivalCity.toLowerCase();
        matches =
            matches &&
            (f.arrivalCityAr.toLowerCase().contains(q) ||
                f.arrivalCityEn.toLowerCase().contains(q));
      }
      return matches;
    }).toList();
  }
}
