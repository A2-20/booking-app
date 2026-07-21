import 'package:flutter/foundation.dart';
import '../models/booking_model.dart';
import '../services/booking_service.dart';

class BookingState extends ChangeNotifier {
  List<BookingModel> _bookings = [];
  bool _isLoading = false;

  List<BookingModel> get bookings => _bookings;
  bool get isLoading => _isLoading;

  Future<void> loadUserBookings(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _bookings = await BookingService.getBookingsByUserId(userId);
    } catch (e) {
      print('Error loading bookings: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addBooking(BookingModel booking) async {
    _bookings.add(booking);
    notifyListeners();
  }

  Future<void> cancelBooking(String bookingId, {String? reason}) async {
    try {
      final updatedBooking = await BookingService.cancelBooking(
        bookingId,
        reason: reason,
      );
      if (updatedBooking != null) {
        final index = _bookings.indexWhere((b) => b.bookingId == bookingId);
        if (index != -1) {
          _bookings[index] = updatedBooking;
          notifyListeners();
        }
      }
    } catch (e) {
      print('Error cancelling booking: $e');
    }
  }

  void clearBookings() {
    _bookings = [];
    notifyListeners();
  }
}
