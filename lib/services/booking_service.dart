import '../core/enums/payment_method.dart';
import '../models/booking_model.dart';
import '../core/enums/booking_type.dart';
import 'api_service.dart';

class BookingService {
  // Create booking
  static Future<BookingModel?> createBooking({
    required String userId,
    required BookingType type,
    required Map<String, dynamic> items,
    required DateTime bookingDate,
    DateTime? checkInDate,
    DateTime? checkOutDate,
    required double totalPrice,
    required PaymentMethod paymentMethod,
    String? notes,
  }) async {
    try {
      final response = await ApiService.post(
        '/bookings',
        data: {
          'booking_id': 'BK${DateTime.now().millisecondsSinceEpoch}',
          'user_id': userId,
          'type': type.name,
          'items': items,
          'booking_date': bookingDate.toIso8601String(),
          'check_in_date': checkInDate?.toIso8601String(),
          'check_out_date': checkOutDate?.toIso8601String(),
          'total_price': totalPrice,
          'payment_method': paymentMethod.name,
          'notes': notes,
        },
      );

      if (response.statusCode == 201) {
        return BookingModel.fromJson(response.data);
      }
    } catch (e) {
      print('Create booking error: $e');
    }
    return null;
  }

  // Get all bookings for current user
  static Future<List<BookingModel>> getBookingsByUserId(String userId) async {
    try {
      final response = await ApiService.get('/bookings');
      if (response.statusCode == 200) {
        return (response.data as List)
            .map((json) => BookingModel.fromJson(json))
            .toList();
      }
    } catch (e) {
      print('Fetch bookings error: $e');
    }
    return [];
  }

  // Cancel booking
  static Future<BookingModel?> cancelBooking(
    String bookingId, {
    String? reason,
  }) async {
    try {
      final response = await ApiService.post(
        '/bookings/$bookingId/cancel',
        data: {'reason': reason},
      );

      if (response.statusCode == 200) {
        return BookingModel.fromJson(response.data);
      }
    } catch (e) {
      print('Cancel booking error: $e');
    }
    return null;
  }

  // Get booking by ID
  static Future<BookingModel?> getBookingById(String bookingId) async {
    try {
      final response = await ApiService.get('/bookings/$bookingId');
      if (response.statusCode == 200) {
        return BookingModel.fromJson(response.data);
      }
    } catch (e) {
      print('Fetch booking by ID error: $e');
    }
    return null;
  }

  // Confirm booking
  static Future<bool> confirmBooking(String bookingId) async {
    try {
      final response = await ApiService.post('/bookings/$bookingId/confirm');
      return response.statusCode == 200;
    } catch (e) {
      print('Confirm booking error: $e');
      return false;
    }
  }
}
