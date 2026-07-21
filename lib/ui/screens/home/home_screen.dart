import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../localization/app_localizations.dart';
import '../../../core/utils/animations.dart';
import '../../../core/utils/page_transitions.dart';
import '../../../theme/app_theme.dart';
import '../search/search_screen.dart';
import '../profile/profile_screen.dart';
import '../booking/bookings_screen.dart';
import '../../components/navigation/animated_tab_bar.dart';
import '../../components/cards/hotel_card.dart';
import '../../components/common/sar_price_text.dart';
import '../../../models/hotel_model.dart';
import '../../../models/flight_model.dart';
import '../../../models/package_model.dart';
import '../../../services/hotel_service.dart';
import '../../../services/flight_service.dart';
import '../../../services/package_service.dart';

import '../flight_details/flight_details_screen.dart';
import '../package_details/package_details_screen.dart';
import '../favorites/favorites_screen.dart';
import '../../../state/booking_state.dart';
import '../../../state/user_state.dart';
import '../../../state/favorites_state.dart';
import '../../../models/booking_model.dart';
import '../booking_details/booking_details_screen.dart';
import '../../../core/enums/booking_status.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  List<HotelModel> _hotels = [];
  List<FlightModel> _flights = [];
  List<PackageModel> _packages = [];
  bool _isLoading = true;
  int _selectedTab = 0;
  bool _showMostLiked = false;

  @override
  void initState() {
    super.initState();
    // Resolve "setState() or markNeedsBuild() called during build" by deferring execution
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAllData();
    });
  }

  Future<void> _loadAllData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    // Listen to booking state if user logged in
    final userState = Provider.of<UserState>(context, listen: false);
    if (userState.currentUser != null) {
      final bookingState = Provider.of<BookingState>(context, listen: false);
      bookingState.loadUserBookings(userState.currentUser!.userId);
    }

    final results = await Future.wait([
      HotelService.getAllHotels(),
      FlightService.getAllFlights(),
      PackageService.getAllPackages(),
    ]);

    if (!mounted) return;
    setState(() {
      _hotels = results[0] as List<HotelModel>;
      _flights = results[1] as List<FlightModel>;
      _packages = results[2] as List<PackageModel>;
      _isLoading = false;
    });

    // Seed favorites counts
    if (mounted) {
      final favState = Provider.of<FavoritesState>(context, listen: false);
      final counts = {for (final h in _hotels) h.hotelId: h.favoritesCount};
      favState.seedCounts(counts);
      if (!favState.initialized) {
        favState.loadFavorites();
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          children: [
            _buildHomePage(localizations),
            const BookingsScreen(),
            const ProfileScreen(),
          ],
        ),
        bottomNavigationBar: _buildBottomNav(localizations),
      ),
    );
  }

  Widget _buildHomePage(AppLocalizations localizations) {
    final userState = Provider.of<UserState>(context);
    final user = userState.currentUser;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Premium App Bar
        SliverAppBar(
          expandedHeight: 200,
          floating: false,
          pinned: true,
          automaticallyImplyLeading: false,
          backgroundColor: AppTheme.primaryColor,
          elevation: 0,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withOpacity(0.8),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // Decorative Circles
                  Positioned(
                    top: -50,
                    right: -50,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AppAnimations.fadeIn(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (user != null)
                                      Text(
                                        '${localizations.locale.languageCode == 'ar' ? 'مرحباً،' : 'Hello,'} ${user.fullName.split(' ')[0]}',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.8),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    Text(
                                      localizations.translate('app_title'),
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineMedium
                                          ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: -0.5,
                                          ),
                                    ),
                                  ],
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.favorite_rounded,
                                          color: Colors.white,
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).push(
                                            AppPageTransitions.slideRoute(
                                              const FavoritesScreen(),
                                            ),
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.notifications_active_outlined,
                                          color: Colors.white,
                                        ),
                                        onPressed: () {},
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          AppAnimations.fadeIn(
                            duration: const Duration(milliseconds: 500),
                            child: Text(
                              localizations.translate('find_perfect_stay'),
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    color: Colors.white.withOpacity(0.7),
                                    fontWeight: FontWeight.w400,
                                  ),
                            ),
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: TabBar(
                onTap: (index) {
                  setState(() {
                    _selectedTab = index;
                  });
                },
                labelColor: Theme.of(context).primaryColor,
                unselectedLabelColor: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withOpacity(0.5),
                indicatorColor: Theme.of(context).primaryColor,
                indicatorWeight: 4,
                indicatorSize: TabBarIndicatorSize.label,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                tabs: [
                  Tab(text: localizations.translate('hotels')),
                  Tab(text: localizations.translate('flights')),
                  Tab(text: localizations.translate('packages')),
                ],
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 40)),

        // Search bar
        SliverToBoxAdapter(
          child: Transform.translate(
            offset: const Offset(0, -30),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: AppAnimations.fadeSlideIn(
                child: Hero(
                  tag: 'search_bar',
                  child: Material(
                    elevation: 10,
                    shadowColor: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    color: Theme.of(context).cardColor,
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          AppPageTransitions.slideRoute(const SearchScreen()),
                        );
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.search_rounded,
                              color: AppTheme.primaryColor,
                            ),
                            const SizedBox(width: 15),
                            Text(
                              localizations.translate('search'),
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.color?.withOpacity(0.6),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              height: 30,
                              width: 1,
                              color: Theme.of(
                                context,
                              ).dividerColor.withOpacity(0.2),
                            ),
                            const SizedBox(width: 15),
                            Icon(
                              Icons.tune_rounded,
                              color: Theme.of(context).primaryColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        // Upcoming Booking Reminder
        SliverToBoxAdapter(
          child: Consumer<BookingState>(
            builder: (context, bookingState, child) {
              final upcoming = _getUpcomingBooking(bookingState.bookings);
              if (upcoming == null) return const SizedBox.shrink();

              return Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: AppAnimations.fadeSlideIn(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.secondaryColor,
                          AppTheme.secondaryColor.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.secondaryColor.withOpacity(0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.calendar_today_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                localizations.translate('upcoming_booking'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            // IconButton(
                            //   onPressed: () {},
                            //   icon: const Icon(
                            //     Icons.close,
                            //     color: Colors.white,
                            //     size: 20,
                            //   ),
                            // ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          localizations.translate('booking_reminder_text'),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                AppPageTransitions.slideRoute(
                                  BookingDetailsScreen(booking: upcoming),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppTheme.secondaryColor,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              localizations.translate('view_details'),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        // Sort toggle (only for hotels tab)
        if (_selectedTab == 0)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: Row(
                children: [
                  Text(
                    localizations.translate('sort_by'),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  _buildSortChip(
                    localizations.translate('all_hotels'),
                    !_showMostLiked,
                    () => setState(() => _showMostLiked = false),
                  ),
                  const SizedBox(width: 8),
                  _buildSortChip(
                    localizations.translate('most_liked'),
                    _showMostLiked,
                    () => setState(() => _showMostLiked = true),
                    icon: Icons.favorite_rounded,
                  ),
                ],
              ),
            ),
          ),
        // Sections Header
        SliverToBoxAdapter(
          child: AppAnimations.fadeIn(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(26, 0, 26, 15),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _getContentTitle(localizations),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${_getContentCount()} ${localizations.translate(_getContentKey())}',
                    style: TextStyle(
                      color: AppTheme.textSecondary.withOpacity(0.8),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_isLoading)
          const SliverFillRemaining(
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.primaryColor,
                ),
              ),
            ),
          )
        else
          _buildTabContent(localizations),
        const SliverToBoxAdapter(child: SizedBox(height: 30)),
      ],
    );
  }

  String _getContentTitle(AppLocalizations localizations) {
    switch (_selectedTab) {
      case 0:
        return localizations.translate('hotels');
      case 1:
        return localizations.translate('flights');
      case 2:
        return localizations.translate('packages');
      default:
        return '';
    }
  }

  String _getContentKey() {
    switch (_selectedTab) {
      case 0:
        return 'hotels';
      case 1:
        return 'flights';
      case 2:
        return 'packages';
      default:
        return '';
    }
  }

  int _getContentCount() {
    switch (_selectedTab) {
      case 0:
        return _hotels.length;
      case 1:
        return _flights.length;
      case 2:
        return _packages.length;
      default:
        return 0;
    }
  }

  Widget _buildTabContent(AppLocalizations localizations) {
    if (_selectedTab == 0) {
      // Sort hotels: by favorites count if 'most liked' is selected
      final favState = Provider.of<FavoritesState>(context, listen: false);
      final sortedHotels = List<HotelModel>.from(_hotels);
      if (_showMostLiked) {
        sortedHotels.sort(
          (a, b) => favState
              .getFavoritesCount(b.hotelId)
              .compareTo(favState.getFavoritesCount(a.hotelId)),
        );
      }
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            return HotelCard(hotel: sortedHotels[index], index: index);
          }, childCount: sortedHotels.length),
        ),
      );
    } else if (_selectedTab == 1) {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final flight = _flights[index];
            return AppAnimations.fadeSlideIn(
              child: Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: flight.images.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              flight.images[0],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                    Icons.flight_takeoff_rounded,
                                    color: AppTheme.primaryColor,
                                  ),
                            ),
                          )
                        : const Icon(
                            Icons.flight_takeoff_rounded,
                            color: AppTheme.primaryColor,
                          ),
                  ),
                  title: Text(
                    '${flight.getDepartureCity(localizations.locale.languageCode)} → ${flight.getArrivalCity(localizations.locale.languageCode)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${flight.getAirline(localizations.locale.languageCode)} • ${flight.departureTime}',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                  trailing: SarPriceText(
                    price: '${flight.price}',
                    fontSize: 16,
                    color: AppTheme.primaryColor,
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      AppPageTransitions.slideRoute(
                        FlightDetailsScreen(flight: flight),
                      ),
                    );
                  },
                ),
              ),
            );
          }, childCount: _flights.length),
        ),
      );
    } else {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final package = _packages[index];
            return AppAnimations.fadeSlideIn(
              child: Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: package.images.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              package.images[0],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                    Icons.card_travel_rounded,
                                    color: AppTheme.primaryColor,
                                  ),
                            ),
                          )
                        : const Icon(
                            Icons.card_travel_rounded,
                            color: AppTheme.primaryColor,
                          ),
                  ),
                  title: Text(
                    package.getName(localizations.locale.languageCode),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${package.nights} ${localizations.translate('nights')}',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                  trailing: SarPriceText(
                    price: '${package.finalPrice}',
                    fontSize: 16,
                    color: AppTheme.primaryColor,
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      AppPageTransitions.slideRoute(
                        PackageDetailsScreen(package: package),
                      ),
                    );
                  },
                ),
              ),
            );
          }, childCount: _packages.length),
        ),
      );
    }
  }

  Widget _buildSortChip(
    String label,
    bool isSelected,
    VoidCallback onTap, {
    IconData? icon,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryColor
                : Theme.of(context).dividerColor.withOpacity(0.2),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: isSelected ?AppTheme.borderColor : AppTheme.textSecondary,
              ),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : Theme.of(context).textTheme.bodyMedium?.color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(AppLocalizations localizations) {
    return AnimatedTabBar(
      currentIndex: _currentIndex,
      onTap: _onTabTapped,
      activeColor: Theme.of(context).primaryColor,
      inactiveColor:
          Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey,
      backgroundColor: Theme.of(context).cardColor,
      items: [
        AnimatedTabItem(
          icon: Icons.home_rounded,
          label: localizations.translate('home'),
        ),
        AnimatedTabItem(
          icon: Icons.bookmark_rounded,
          label: localizations.translate('bookings'),
        ),
        AnimatedTabItem(
          icon: Icons.person_rounded,
          label: localizations.translate('profile'),
        ),
      ],
    );
  }

  BookingModel? _getUpcomingBooking(List<BookingModel> bookings) {
    if (bookings.isEmpty) return null;
    final now = DateTime.now();
    // Return the first confirmed booking that is in the future
    try {
      return bookings.firstWhere(
        (b) =>
            b.status == BookingStatus.confirmed &&
            b.checkInDate != null &&
            b.checkInDate!.isAfter(now),
      );
    } catch (e) {
      return null;
    }
  }
}
