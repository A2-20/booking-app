import '../core/enums/payment_method.dart';
import '../core/enums/payment_status.dart';
import '../core/enums/booking_type.dart';
import '../core/enums/booking_status.dart';

class BookingModel {
  final String bookingId;
  final String userId;
  final BookingType type;
  final Map<String, dynamic> items; // hotelId, flightId, packageId, etc.
  final DateTime bookingDate;
  final DateTime? checkInDate;
  final DateTime? checkOutDate;
  final BookingStatus status;
  final double totalPrice;
  final PaymentMethod paymentMethod;
  final PaymentStatus paymentStatus;
  final String? notes;
  final String? cancellationReason;

  BookingModel({
    required this.bookingId,
    required this.userId,
    required this.type,
    required this.items,
    required this.bookingDate,
    this.checkInDate,
    this.checkOutDate,
    this.status = BookingStatus.pending,
    required this.totalPrice,
    this.paymentMethod = PaymentMethod.card,
    this.paymentStatus = PaymentStatus.pending,
    this.notes,
    this.cancellationReason,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic date) {
      if (date is String) {
        return DateTime.tryParse(date) ?? DateTime.now();
      } else if (date is int) {
        return DateTime.fromMillisecondsSinceEpoch(date);
      }
      return DateTime.now();
    }

    return BookingModel(
      bookingId: (json['bookingId'] ?? json['booking_id'] ?? '').toString(),
      userId: (json['userId'] ?? json['user_id'] ?? '').toString(),
      type: BookingType.values.firstWhere(
        (e) => e.name == (json['type'] ?? ''),
        orElse: () => BookingType.hotel,
      ),
      items: (json['items'] is Map)
          ? Map<String, dynamic>.from(json['items'])
          : {},
      bookingDate: parseDate(json['bookingDate'] ?? json['booking_date']),
      checkInDate: (json['checkInDate'] ?? json['check_in_date']) != null
          ? parseDate(json['checkInDate'] ?? json['check_in_date'])
          : null,
      checkOutDate: (json['checkOutDate'] ?? json['check_out_date']) != null
          ? parseDate(json['checkOutDate'] ?? json['check_out_date'])
          : null,
      status: BookingStatus.values.firstWhere(
        (e) => e.name == (json['status'] ?? ''),
        orElse: () => BookingStatus.pending,
      ),
      totalPrice: (json['totalPrice'] ?? json['total_price'] ?? 0.0) is num
          ? (json['totalPrice'] ?? json['total_price'] ?? 0.0).toDouble()
          : double.tryParse(
                  (json['totalPrice'] ?? json['total_price'] ?? '0.0')
                      .toString(),
                ) ??
                0.0,
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) =>
            e.name == (json['paymentMethod'] ?? json['payment_method'] ?? ''),
        orElse: () => PaymentMethod.card,
      ),
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) =>
            e.name == (json['paymentStatus'] ?? json['payment_status'] ?? ''),
        orElse: () => PaymentStatus.pending,
      ),
      notes: json['notes'] as String? ?? json['notes'].toString(),
      cancellationReason:
          (json['cancellationReason'] ?? json['cancellation_reason'] ?? '')
              .toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookingId': bookingId,
      'userId': userId,
      'type': type.name,
      'items': items,
      'bookingDate': bookingDate.toIso8601String(),
      'checkInDate': checkInDate?.toIso8601String(),
      'checkOutDate': checkOutDate?.toIso8601String(),
      'status': status.name,
      'totalPrice': totalPrice,
      'paymentMethod': paymentMethod.name,
      'paymentStatus': paymentStatus.name,
      'notes': notes,
      'cancellationReason': cancellationReason,
    };
  }

  BookingModel copyWith({
    String? bookingId,
    String? userId,
    BookingType? type,
    Map<String, dynamic>? items,
    DateTime? bookingDate,
    DateTime? checkInDate,
    DateTime? checkOutDate,
    BookingStatus? status,
    double? totalPrice,
    PaymentMethod? paymentMethod,
    PaymentStatus? paymentStatus,
    String? notes,
    String? cancellationReason,
  }) {
    return BookingModel(
      bookingId: bookingId ?? this.bookingId,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      items: items ?? this.items,
      bookingDate: bookingDate ?? this.bookingDate,
      checkInDate: checkInDate ?? this.checkInDate,
      checkOutDate: checkOutDate ?? this.checkOutDate,
      status: status ?? this.status,
      totalPrice: totalPrice ?? this.totalPrice,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      notes: notes ?? this.notes,
      cancellationReason: cancellationReason ?? this.cancellationReason,
    );
  }
}
