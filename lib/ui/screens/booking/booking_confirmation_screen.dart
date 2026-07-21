import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../state/user_state.dart';
import '../../../state/booking_state.dart';
import '../../../core/enums/booking_type.dart';
import '../../../core/enums/payment_method.dart';
import '../../../services/booking_service.dart';
import '../../../services/room_service.dart';
import '../../../localization/app_localizations.dart';
import 'payment_screen.dart';
import '../home/home_screen.dart';
import '../../../core/utils/app_messages.dart';
import '../../../services/flight_service.dart';
import '../../../services/package_service.dart';
import '../../components/common/sar_price_text.dart';

class BookingConfirmationScreen extends StatefulWidget {
  final String? hotelId;
  final String? roomId;
  final String? flightId;
  final String? packageId;
  final String type; // 'hotel', 'flight', 'package'

  const BookingConfirmationScreen({
    super.key,
    this.hotelId,
    this.roomId,
    this.flightId,
    this.packageId,
    required this.type,
  });

  @override
  State<BookingConfirmationScreen> createState() =>
      _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  int _nights = 1;
  double _totalPrice = 0.0;
  bool _isLoading = true;
  PaymentMethod _selectedPaymentMethod = PaymentMethod.card;

  @override
  void initState() {
    super.initState();
    _calculatePrice();
  }

  Future<void> _calculatePrice() async {
    if (widget.type == 'hotel' &&
        widget.roomId != null &&
        widget.hotelId != null) {
      final room = await RoomService.getRoomById(
        widget.hotelId!,
        widget.roomId!,
      );
      if (room != null) {
        setState(() {
          _totalPrice = room.pricePerNight * _nights;
          _isLoading = false;
        });
      }
    } else if (widget.type == 'flight' && widget.flightId != null) {
      final flight = await FlightService.getFlightById(widget.flightId!);
      if (mounted) {
        setState(() {
          _totalPrice = flight?.price ?? 0.0;
          _isLoading = false;
        });
      }
    } else if (widget.type == 'package' && widget.packageId != null) {
      final package = await PackageService.getPackageById(widget.packageId!);
      if (mounted) {
        setState(() {
          _totalPrice = package?.finalPrice ?? 0.0;
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectCheckInDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        _checkInDate = date;
        if (_checkOutDate != null && _checkOutDate!.isBefore(_checkInDate!)) {
          _checkOutDate = null;
        }
      });
      _calculateNights();
    }
  }

  Future<void> _selectCheckOutDate() async {
    if (_checkInDate == null) {
      AppMessages.showWarning(
        context,
        AppLocalizations.of(context)!.translate('check_in'),
      );
      return;
    }

    final date = await showDatePicker(
      context: context,
      initialDate: _checkInDate!.add(const Duration(days: 1)),
      firstDate: _checkInDate!.add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        _checkOutDate = date;
      });
      _calculateNights();
    }
  }

  void _calculateNights() {
    if (_checkInDate != null && _checkOutDate != null) {
      setState(() {
        _nights = _checkOutDate!.difference(_checkInDate!).inDays;
        if (_nights < 1) _nights = 1;
      });
      _calculatePrice();
    }
  }

  Future<void> _confirmBooking() async {
    final localizations = AppLocalizations.of(context)!;
    final userState = Provider.of<UserState>(context, listen: false);
    if (userState.currentUser == null) {
      AppMessages.showError(
        context,
        AppLocalizations.of(context)!.translate('please_login_first'),
      );
      return;
    }

    if (widget.type == 'hotel' &&
        (_checkInDate == null || _checkOutDate == null)) {
      AppMessages.showWarning(
        context,
        AppLocalizations.of(context)!.translate('select_check_in_out'),
      );
      return;
    }

    final items = <String, dynamic>{
      if (widget.hotelId != null) 'hotelId': widget.hotelId,
      if (widget.roomId != null) 'roomId': widget.roomId,
      if (widget.flightId != null) 'flightId': widget.flightId,
      if (widget.packageId != null) 'packageId': widget.packageId,
    };

    BookingType bookingType;
    if (widget.type == 'hotel') {
      bookingType = BookingType.hotel;
    } else if (widget.type == 'flight') {
      bookingType = BookingType.flight;
    } else {
      bookingType = BookingType.package;
    }

    final booking = await BookingService.createBooking(
      userId: userState.currentUser!.userId,
      type: bookingType,
      items: items,
      bookingDate: DateTime.now(),
      checkInDate: _checkInDate,
      checkOutDate: _checkOutDate,
      totalPrice: _totalPrice,
      paymentMethod: _selectedPaymentMethod,
    );

    if (booking == null) {
      if (mounted) {
        AppMessages.showError(
          context,
          AppLocalizations.of(context)!.translate('error'),
        );
      }
      return;
    }

    final bookingState = Provider.of<BookingState>(context, listen: false);
    await bookingState.addBooking(booking);

    if (mounted) {
      if (_selectedPaymentMethod == PaymentMethod.cash) {
        AppMessages.showSuccess(
          context,
          localizations.translate('booking_confirmed'),
        );
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      } else {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PaymentScreen(bookingId: booking.bookingId),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text(localizations.translate('confirm_booking')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.type == 'hotel') ...[
              ListTile(
                title: Text(localizations.translate('check_in')),
                subtitle: Text(
                  _checkInDate?.toString().split(' ')[0] ??
                      localizations.translate('select_date'),
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: _selectCheckInDate,
              ),
              ListTile(
                title: Text(localizations.translate('check_out')),
                subtitle: Text(
                  _checkOutDate?.toString().split(' ')[0] ??
                      localizations.translate('select_date'),
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: _selectCheckOutDate,
              ),
              if (_nights > 0)
                ListTile(
                  title: Text('${localizations.translate('nights')}: $_nights'),
                ),
            ],
            const Divider(),
            ListTile(
              title: Text(localizations.translate('total')),
              trailing: SarPriceText(
                price: '$_totalPrice',
                fontSize: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                localizations.translate('payment_method'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            RadioListTile<PaymentMethod>(
              title: Text(localizations.translate('card')),
              value: PaymentMethod.card,
              groupValue: _selectedPaymentMethod,
              onChanged: (value) {
                setState(() {
                  _selectedPaymentMethod = value!;
                });
              },
            ),
            RadioListTile<PaymentMethod>(
              title: Text(localizations.translate('cash')),
              value: PaymentMethod.cash,
              groupValue: _selectedPaymentMethod,
              onChanged: (value) {
                setState(() {
                  _selectedPaymentMethod = value!;
                });
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _confirmBooking,
              child: Text(localizations.translate('confirm_booking')),
            ),
          ],
        ),
      ),
    );
  }
}
