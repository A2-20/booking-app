import '../core/enums/payment_method.dart';
import '../core/enums/payment_status.dart';

class PaymentModel {
  final String paymentId;
  final String bookingId;
  final PaymentMethod method;
  final PaymentStatus status;
  final double amount;
  final DateTime paymentDate;
  final String? transactionId;

  PaymentModel({
    required this.paymentId,
    required this.bookingId,
    required this.method,
    required this.status,
    required this.amount,
    required this.paymentDate,
    this.transactionId,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic date) {
      if (date is String) {
        return DateTime.parse(date);
      } else if (date is int) {
        return DateTime.fromMillisecondsSinceEpoch(date);
      }
      return DateTime.now();
    }

    return PaymentModel(
      paymentId: json['paymentId'] as String,
      bookingId: json['bookingId'] as String,
      method: PaymentMethod.values.firstWhere(
        (e) => e.name == json['method'],
        orElse: () => PaymentMethod.card,
      ),
      status: PaymentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => PaymentStatus.pending,
      ),
      amount: (json['amount'] as num).toDouble(),
      paymentDate: parseDate(json['paymentDate']),
      transactionId: json['transactionId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'paymentId': paymentId,
      'bookingId': bookingId,
      'method': method.name,
      'status': status.name,
      'amount': amount,
      'paymentDate': paymentDate.toIso8601String(),
      'transactionId': transactionId,
    };
  }
}
