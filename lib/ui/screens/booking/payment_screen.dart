import 'package:flutter/material.dart';
import '../../../core/enums/payment_method.dart';
import '../../../services/payment_service.dart';
import '../../../services/booking_service.dart';
import '../../../services/stripe_service.dart';
import '../../../core/enums/payment_status.dart';
import '../../../localization/app_localizations.dart';
import '../home/home_screen.dart';
import '../../../core/utils/app_messages.dart';

class PaymentScreen extends StatefulWidget {
  final String bookingId;

  const PaymentScreen({super.key, required this.bookingId});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  PaymentMethod _selectedMethod = PaymentMethod.card;
  bool _isProcessing = false;

  Future<void> _processPayment() async {
    setState(() {
      _isProcessing = true;
    });

    final booking = await BookingService.getBookingById(widget.bookingId);
    if (booking == null) {
      if (mounted) {
        setState(() => _isProcessing = false);
        AppMessages.showError(
          context,
          AppLocalizations.of(context)!.translate('error'),
        );
      }
      return;
    }

    bool isSuccess = false;

    if (_selectedMethod == PaymentMethod.card) {
      try {
        // Stripe integration
        await StripeService.initPaymentSheet(
          amount: (booking.totalPrice).toStringAsFixed(0),
          currency: 'SAR',
        );
        isSuccess = await StripeService.displayPaymentSheet();
      } catch (e) {
        debugPrint('Stripe error: $e');
        isSuccess = false;
      }
    } else {
      // Logic for cash or other methods
      final payment = await PaymentService.processPayment(
        bookingId: widget.bookingId,
        method: _selectedMethod,
        amount: booking.totalPrice,
      );
      isSuccess =
          payment.status == PaymentStatus.paid ||
          (_selectedMethod == PaymentMethod.cash &&
              payment.status == PaymentStatus.pending);
    }

    if (mounted) {
      setState(() {
        _isProcessing = false;
      });

      if (isSuccess) {
        await BookingService.confirmBooking(widget.bookingId);

        if (mounted) {
          AppMessages.showSuccess(
            context,
            AppLocalizations.of(context)!.translate('booking_confirmed'),
          );

          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
            (route) => false,
          );
        }
      } else {
        if (mounted) {
          AppMessages.showError(
            context,
            AppLocalizations.of(context)!.translate('payment_failed'),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text(localizations.translate('payment')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              localizations.translate('payment_method'),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            RadioListTile<PaymentMethod>(
              title: Text(localizations.translate('card')),
              value: PaymentMethod.card,
              groupValue: _selectedMethod,
              onChanged: (value) {
                setState(() {
                  _selectedMethod = value!;
                });
              },
            ),
            RadioListTile<PaymentMethod>(
              title: Text(localizations.translate('cash')),
              value: PaymentMethod.cash,
              groupValue: _selectedMethod,
              onChanged: (value) {
                setState(() {
                  _selectedMethod = value!;
                });
              },
            ),
            const SizedBox(height: 32),
            if (_isProcessing)
              const Center(child: CircularProgressIndicator())
            else
              ElevatedButton(
                onPressed: _processPayment,
                child: Text(localizations.translate('payment')),
              ),
          ],
        ),
      ),
    );
  }
}
