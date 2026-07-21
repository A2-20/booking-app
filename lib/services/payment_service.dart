import 'package:uuid/uuid.dart';
import '../models/payment_model.dart';
import '../core/enums/payment_method.dart';
import '../core/enums/payment_status.dart';
import '../storage/local_storage_manager.dart';

class PaymentService {
  static const _uuid = Uuid();

  // Process payment (mock)
  static Future<PaymentModel> processPayment({
    required String bookingId,
    required PaymentMethod method,
    required double amount,
  }) async {
    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 1));

    final isSuccess =
        method == PaymentMethod.cash || (DateTime.now().millisecond % 10 != 0);

    final payment = PaymentModel(
      paymentId: _uuid.v4(),
      bookingId: bookingId,
      method: method,
      status: method == PaymentMethod.cash
          ? PaymentStatus.pending
          : (isSuccess ? PaymentStatus.paid : PaymentStatus.failed),
      amount: amount,
      paymentDate: DateTime.now(),
      transactionId: isSuccess
          ? 'TXN_${DateTime.now().millisecondsSinceEpoch}'
          : null,
    );

    final paymentsData = await LocalStorageManager.getPayments();
    paymentsData.add(payment.toJson());
    await LocalStorageManager.savePayments(paymentsData);

    // If payment successful, confirm booking
    if (isSuccess) {
      // This would typically be handled by booking service
    }

    return payment;
  }

  // Get payment by booking ID
  static Future<PaymentModel?> getPaymentByBookingId(String bookingId) async {
    final paymentsData = await LocalStorageManager.getPayments();
    try {
      final paymentJson = paymentsData.firstWhere(
        (p) => p['bookingId'] == bookingId,
      );
      return PaymentModel.fromJson(paymentJson);
    } catch (e) {
      return null;
    }
  }

  // Get all payments
  static Future<List<PaymentModel>> getAllPayments() async {
    final paymentsData = await LocalStorageManager.getPayments();
    return paymentsData.map((json) => PaymentModel.fromJson(json)).toList();
  }
}
