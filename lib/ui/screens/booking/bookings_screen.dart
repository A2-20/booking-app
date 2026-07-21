import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../state/user_state.dart';
import '../../../state/booking_state.dart';
import '../../../core/enums/booking_status.dart';
import '../../../core/enums/payment_status.dart';
import '../../../localization/app_localizations.dart';

import '../../../theme/app_theme.dart';
import '../../../core/utils/animations.dart';
import '../../../core/utils/page_transitions.dart';
import '../../components/loaders/loading_widget.dart';
import '../../../core/utils/app_messages.dart';
import '../../components/common/sar_price_text.dart';

import '../../screens/booking_details/booking_details_screen.dart';
import '../../../models/booking_model.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBookings();
    });
  }

  Future<void> _loadBookings() async {
    final userState = Provider.of<UserState>(context, listen: false);
    if (userState.currentUser != null) {
      final bookingState = Provider.of<BookingState>(context, listen: false);
      await bookingState.loadUserBookings(userState.currentUser!.userId);
    }
  }

  Future<void> _cancelBooking(String bookingId) async {
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

    if (result != null && mounted) {
      await bookingState.cancelBooking(bookingId, reason: result);
      if (mounted) {
        AppMessages.showSuccess(context, localizations.translate('success'));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final userState = Provider.of<UserState>(context);
    final bookingState = Provider.of<BookingState>(context);

    // Filter bookings
    final activeBookings = bookingState.bookings
        .where(
          (b) =>
              b.status == BookingStatus.pending ||
              b.status == BookingStatus.confirmed,
        )
        .toList();
    final pastBookings = bookingState.bookings
        .where((b) => b.status == BookingStatus.cancelled)
        .toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // App Bar
            SliverAppBar(
              expandedHeight: 200,
              floating: false,
              pinned: true,
              automaticallyImplyLeading: false,
              backgroundColor: AppTheme.primaryColor,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(gradient: AppTheme.primaryGradient),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AppAnimations.fadeIn(
                            child: Text(
                              localizations.translate('bookings'),
                              style: Theme.of(context).textTheme.displaySmall
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.5,
                                  ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          AppAnimations.fadeIn(
                            duration: const Duration(milliseconds: 500),
                            child: Text(
                              '${bookingState.bookings.length} ${localizations.translate('bookings')}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(height: 48), // Space for tabs
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Container(
                  color: Colors.transparent,
                  child: TabBar(
                    indicatorColor: Colors.white,
                    indicatorWeight: 3,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white.withOpacity(0.6),
                    tabs: [
                      Tab(text: localizations.translate('active_bookings')),
                      Tab(text: localizations.translate('past_bookings')),
                    ],
                  ),
                ),
              ),
            ),
            // Content
            if (userState.currentUser == null)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.bookmark_border_rounded,
                        size: 80,
                        color: AppTheme.textSecondary.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        localizations.translate('please_login_first'),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                ),
              )
            else if (bookingState.isLoading)
              const SliverFillRemaining(child: LoadingWidget())
            else
              SliverFillRemaining(
                child: TabBarView(
                  children: [
                    _buildBookingList(activeBookings, localizations),
                    _buildBookingList(pastBookings, localizations),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingList(
    List<BookingModel> bookings,
    AppLocalizations localizations,
  ) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bookmark_border_rounded,
              size: 80,
              color: AppTheme.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              localizations.translate('no_results'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return AppAnimations.fadeSlideIn(
          offset: const Offset(0, 20),
          duration: Duration(milliseconds: 300 + (index * 100)),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
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
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  AppPageTransitions.slideRoute(
                    BookingDetailsScreen(booking: booking),
                  ),
                );
              },
              onLongPress: () {
                if (booking.status != BookingStatus.cancelled) {
                  _cancelBooking(booking.bookingId);
                }
              },
              borderRadius: BorderRadius.circular(24),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: booking.status == BookingStatus.confirmed
                            ? AppTheme.successColor.withOpacity(0.1)
                            : booking.status == BookingStatus.cancelled
                            ? AppTheme.errorColor.withOpacity(0.1)
                            : AppTheme.warningColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        booking.status == BookingStatus.confirmed
                            ? Icons.check_circle_rounded
                            : booking.status == BookingStatus.cancelled
                            ? Icons.cancel_rounded
                            : Icons.pending_rounded,
                        color: booking.status == BookingStatus.confirmed
                            ? AppTheme.successColor
                            : booking.status == BookingStatus.cancelled
                            ? AppTheme.errorColor
                            : AppTheme.warningColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            localizations.translate(booking.type.displayName),
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                '${localizations.translate('total')}: ',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              SarPriceText(
                                price: '${booking.totalPrice}',
                                fontSize: 13,
                                color: AppTheme.primaryColor,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            booking.paymentStatus == PaymentStatus.paid
                                ? localizations.translate('paid')
                                : localizations.translate('unpaid'),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: booking.paymentStatus == PaymentStatus.paid
                                  ? AppTheme.successColor
                                  : AppTheme.errorColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: AppTheme.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
