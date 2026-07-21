import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'api_service.dart';

class StripeService {
  static Future<void> initPaymentSheet({
    required String amount,
    required String currency,
  }) async {
    try {
      // 1. Create PaymentIntent on the backend
      final response = await ApiService.post(
        '/payment/intent',
        data: {'amount': amount, 'currency': currency},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to create payment intent');
      }

      final data = response.data;
      final paymentIntentClientSecret = data['client_secret'];
      final customerId = data['customer'];
      final ephemeralKeySecret = data['ephemeral_key'];

      // 2. Initialize the payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentClientSecret,
          customerEphemeralKeySecret: ephemeralKeySecret,
          customerId: customerId,
          merchantDisplayName: 'Booking App',
          style: ThemeMode.system,
        ),
      );
    } catch (e) {
      debugPrint('Error initializing payment sheet: $e');
      rethrow;
    }
  }

  static Future<bool> displayPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet();
      debugPrint('Payment successful');
      return true;
    } on StripeException catch (e) {
      debugPrint('Stripe error: ${e.error.localizedMessage}');
      return false;
    } catch (e) {
      debugPrint('Error displaying payment sheet: $e');
      return false;
    }
  }
}
