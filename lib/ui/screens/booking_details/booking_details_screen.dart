import 'package:flutter/material.dart';
import '../../../../models/booking_model.dart';
import '../../../../core/enums/booking_status.dart';
import '../../../../core/enums/payment_method.dart';
import '../../../../core/enums/payment_status.dart';
import '../../../../localization/app_localizations.dart';

import '../../../../theme/app_theme.dart';
import '../../../../core/utils/animations.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../state/booking_state.dart';
import '../../../../core/utils/app_messages.dart';
import '../../../../services/hotel_service.dart';
import '../../../../services/flight_service.dart';
import '../../../../models/hotel_model.dart';
import '../../../../models/flight_model.dart';
import '../../../../core/enums/booking_type.dart';
import '../../../../ui/components/common/sar_price_text.dart';

class BookingDetailsScreen extends StatelessWidget {
  final BookingModel booking;

  const BookingDetailsScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                color: Theme.of(context).iconTheme.color,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(gradient: AppTheme.primaryGradient),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long_rounded,
                        size: 60,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${localizations.translate('booking_id')} #${booking.bookingId.substring(0, 8)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: AppAnimations.fadeSlideIn(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status and Date
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                localizations.translate('status'),
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(
                                    booking.status,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  localizations.translate(booking.status.name),
                                  style: TextStyle(
                                    color: _getStatusColor(booking.status),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 32),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                localizations.translate('date'),
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                booking.bookingDate.toString().split(' ')[0],
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Details
                    Text(
                      localizations.translate('booking_details'),
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow(
                            context,
                            localizations.translate('type'),
                            localizations.translate(booking.type.displayName),
                          ),
                          const SizedBox(height: 16),
                          _buildDetailRow(
                            context,
                            localizations.translate('payment_method'),
                            booking.paymentMethod == PaymentMethod.cash
                                ? localizations.translate('cash')
                                : localizations.translate('card'),
                          ),
                          const SizedBox(height: 16),
                          _buildDetailRow(
                            context,
                            localizations.translate('payment_status'),
                            booking.paymentStatus == PaymentStatus.paid
                                ? localizations.translate('paid')
                                : localizations.translate('unpaid'),
                            valueColor:
                                booking.paymentStatus == PaymentStatus.paid
                                ? AppTheme.successColor
                                : AppTheme.errorColor,
                            isBold: true,
                          ),
                          if (booking.checkInDate != null) ...[
                            const SizedBox(height: 16),
                            _buildDetailRow(
                              context,
                              localizations.translate('check_in'),
                              booking.checkInDate.toString().split(' ')[0],
                            ),
                          ],
                          if (booking.checkOutDate != null) ...[
                            const SizedBox(height: 16),
                            _buildDetailRow(
                              context,
                              localizations.translate('check_out'),
                              booking.checkOutDate.toString().split(' ')[0],
                            ),
                          ],
                          _buildItemInfo(context, booking, localizations),
                          const Divider(height: 32),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                localizations.translate('total'),
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).textTheme.bodySmall?.color,
                                    ),
                              ),
                              SarPriceText(
                                price: '${booking.totalPrice}',
                                fontSize: 16,
                                color: Theme.of(context).primaryColor,
                              ),
                            ],
                          ),
                          if (booking.status == BookingStatus.cancelled &&
                              booking.cancellationReason != null) ...[
                            const Divider(height: 32),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  localizations.translate(
                                    'cancellation_reason',
                                  ),
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(color: AppTheme.errorColor),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  booking.cancellationReason!,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (booking.status != BookingStatus.cancelled) ...[
                      const SizedBox(height: 40),
                      _buildCancelButton(context, localizations),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemInfo(
    BuildContext context,
    BookingModel booking,
    AppLocalizations localizations,
  ) {
    if (booking.type == BookingType.hotel &&
        booking.items.containsKey('hotelId')) {
      return FutureBuilder<HotelModel?>(
        future: HotelService.getHotelById(booking.items['hotelId']),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final hotel = snapshot.data;
          if (hotel == null) return const SizedBox.shrink();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildDetailRow(
                context,
                localizations.translate('hotel'),
                hotel.getName(localizations.locale.languageCode),
              ),
              const SizedBox(height: 16),
              _buildDetailRow(
                context,
                localizations.translate('location'),
                '${hotel.getCity(localizations.locale.languageCode)}, ${hotel.getCountry(localizations.locale.languageCode)}',
              ),
              if (booking.items.containsKey('room_number') && booking.items['room_number'] != null && booking.items['room_number'].toString().isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildDetailRow(
                  context,
                  localizations.translate('room_number'),
                  booking.items['room_number'].toString(),
                  isBold: true,
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _openGoogleMaps(
                    '${hotel.getName(localizations.locale.languageCode)} ${hotel.getCity(localizations.locale.languageCode)}',
                  ),
                  icon: const Icon(Icons.map_rounded),
                  label: Text(localizations.translate('open_in_maps')),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      );
    } else if (booking.type == BookingType.flight &&
        booking.items.containsKey('flightId')) {
      return FutureBuilder<FlightModel?>(
        future: FlightService.getFlightById(booking.items['flightId']),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final flight = snapshot.data;
          if (flight == null) return const SizedBox.shrink();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildDetailRow(
                context,
                localizations.translate('airline'),
                flight.getAirline(localizations.locale.languageCode),
              ),
              const SizedBox(height: 16),
              _buildDetailRow(
                context,
                localizations.translate('departure'),
                '${flight.getDepartureCity(localizations.locale.languageCode)} (${flight.departureTime})',
              ),
              const SizedBox(height: 16),
              _buildDetailRow(
                context,
                localizations.translate('arrival'),
                '${flight.getArrivalCity(localizations.locale.languageCode)} (${flight.arrivalTime})',
              ),
            ],
          );
        },
      );
    }
    return const SizedBox.shrink();
  }

  Future<void> _openGoogleMaps(String query) async {
    final encodedQuery = Uri.encodeComponent(query);
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$encodedQuery',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: valueColor ?? Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.confirmed:
        return AppTheme.successColor;
      case BookingStatus.cancelled:
        return AppTheme.errorColor;
      default:
        return AppTheme.warningColor;
    }
  }

  Widget _buildCancelButton(
    BuildContext context,
    AppLocalizations localizations,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.errorColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.errorColor.withOpacity(0.2)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showCancelDialog(context),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.cancel_outlined,
                  color: AppTheme.errorColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  localizations.translate('cancel_booking'),
                  style: const TextStyle(
                    color: AppTheme.errorColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showCancelDialog(BuildContext context) async {
    final localizations = AppLocalizations.of(context)!;
    final bookingState = Provider.of<BookingState>(context, listen: false);
    String? selectedReason;
    final otherReasonController = TextEditingController();

    final reasons = [
      'reason_changed_mind',
      'reason_better_price',
      'reason_travel_plans',
      'reason_booking_error',
      'reason_other',
    ];

    final result = await showDialog<String?>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            backgroundColor: Colors.white,
            title: Text(
              localizations.translate('cancel_booking'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    localizations.translate('select_reason'),
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  ...reasons.map((reasonKey) {
                    final localizedReason = localizations.translate(reasonKey);
                    return RadioListTile<String>(
                      title: Text(localizedReason),
                      value: localizedReason,
                      groupValue: selectedReason,
                      activeColor: AppTheme.errorColor,
                      onChanged: (value) {
                        setDialogState(() {
                          selectedReason = value;
                        });
                      },
                    );
                  }),
                  if (selectedReason ==
                      localizations.translate('reason_other')) ...[
                    const SizedBox(height: 8),
                    TextField(
                      controller: otherReasonController,
                      decoration: InputDecoration(
                        hintText: localizations.translate('enter_reason'),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppTheme.errorColor,
                          ),
                        ),
                      ),
                      maxLines: 2,
                    ),
                  ],
                ],
              ),
            ),
            actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(null),
                child: Text(
                  localizations.translate('cancel'),
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
              ElevatedButton(
                onPressed: selectedReason == null
                    ? null
                    : () {
                        String finalReason = selectedReason!;
                        if (finalReason ==
                            localizations.translate('reason_other')) {
                          finalReason = otherReasonController.text.isNotEmpty
                              ? otherReasonController.text
                              : localizations.translate('reason_other');
                        }
                        Navigator.of(context).pop(finalReason);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.errorColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(localizations.translate('confirm_booking')),
              ),
            ],
          );
        },
      ),
    );

    if (result != null && context.mounted) {
      await bookingState.cancelBooking(booking.bookingId, reason: result);
      if (context.mounted) {
        AppMessages.showSuccess(context, localizations.translate('success'));
        Navigator.of(context).pop();
      }
    }
  }
}
