import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../localization/app_localizations.dart';
import '../../../models/hotel_model.dart';
import '../../../services/hotel_service.dart';
import '../../../state/favorites_state.dart';
import '../../../theme/app_theme.dart';
import '../../../core/utils/animations.dart';
import '../../components/cards/hotel_card.dart';
import '../../components/loaders/loading_widget.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<HotelModel> _allHotels = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final favState = Provider.of<FavoritesState>(context, listen: false);
    final hotels = await HotelService.getAllHotels();

    if (!mounted) return;

    // Load favorites if not yet initialized
    if (!favState.initialized) {
      await favState.loadFavorites();
    }

    // Seed favorites counts from the loaded hotels
    final counts = {for (final h in hotels) h.hotelId: h.favoritesCount};
    favState.seedCounts(counts);

    setState(() {
      _allHotels = hotels;
      _isLoading = false;
    });
  }

  List<HotelModel> _getFavoriteHotels(FavoritesState favState) {
    return _allHotels.where((h) => favState.isFavorite(h.hotelId)).toList()
      ..sort(
        (a, b) => favState
            .getFavoritesCount(b.hotelId)
            .compareTo(favState.getFavoritesCount(a.hotelId)),
      );
  }

  HotelModel? _getMostLikedAmongFavorites(
    List<HotelModel> favorites,
    FavoritesState favState,
  ) {
    if (favorites.isEmpty) return null;
    return favorites.reduce(
      (a, b) =>
          favState.getFavoritesCount(a.hotelId) >=
              favState.getFavoritesCount(b.hotelId)
          ? a
          : b,
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final lang = localizations.locale.languageCode;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Consumer<FavoritesState>(
        builder: (context, favState, _) {
          final favoriteHotels = _getFavoriteHotels(favState);
          final topHotel = _getMostLikedAmongFavorites(
            favoriteHotels,
            favState,
          );

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // App Bar
              SliverAppBar(
                expandedHeight: 160,
                pinned: true,
                backgroundColor: AppTheme.primaryColor,
                automaticallyImplyLeading: false,
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [
                          AppTheme.primaryColor,
                          AppTheme.primaryColor.withOpacity(0.75),
                        ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: -40,
                          right: -40,
                          child: Container(
                            width: 180,
                            height: 180,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 40),
                                Text(
                                  localizations.translate('favorites'),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.favorite_rounded,
                                      color: Colors.white70,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${favState.totalUserFavorites} ${localizations.translate('hotels')}',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              if (_isLoading)
                const SliverFillRemaining(child: LoadingWidget())
              else if (favoriteHotels.isEmpty)
                SliverFillRemaining(child: _buildEmptyState(localizations))
              else ...[
                // Stats Section
                SliverToBoxAdapter(
                  child: AppAnimations.fadeSlideIn(
                    child: _buildStatsSection(
                      localizations,
                      favState,
                      favoriteHotels,
                      topHotel,
                      lang,
                    ),
                  ),
                ),

                // Favorites List
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) =>
                          HotelCard(hotel: favoriteHotels[index], index: index),
                      childCount: favoriteHotels.length,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 30)),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatsSection(
    AppLocalizations localizations,
    FavoritesState favState,
    List<HotelModel> favorites,
    HotelModel? topHotel,
    String lang,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats cards row
          Row(
            children: [
              // Total favorites stat
              Expanded(
                child: _buildStatCard(
                  icon: Icons.favorite_rounded,
                  iconColor: Colors.redAccent,
                  bgColor: Colors.red.withOpacity(0.08),
                  label: localizations.translate('total_favorites'),
                  value: '${favState.totalUserFavorites}',
                ),
              ),
              const SizedBox(width: 12),
              // Total likes from all users
              Expanded(
                child: _buildStatCard(
                  icon: Icons.people_rounded,
                  iconColor: AppTheme.primaryColor,
                  bgColor: AppTheme.primaryColor.withOpacity(0.08),
                  label: localizations.translate('likes'),
                  value: favorites
                      .fold<int>(
                        0,
                        (sum, h) => sum + favState.getFavoritesCount(h.hotelId),
                      )
                      .toString(),
                ),
              ),
            ],
          ),

          // Top hotel highlight
          if (topHotel != null) ...[
            const SizedBox(height: 16),
            _buildTopHotelCard(localizations, topHotel, favState, lang),
          ],

          const SizedBox(height: 20),
          // Section header
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                localizations.translate('favorites'),
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: iconColor,
                  ),
                ),
                Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopHotelCard(
    AppLocalizations localizations,
    HotelModel hotel,
    FavoritesState favState,
    String lang,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.redAccent.withOpacity(0.85),
            Colors.orange.withOpacity(0.85),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.redAccent.withOpacity(0.25),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.emoji_events_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizations.translate('top_hotel'),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  hotel.getName(lang),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${hotel.getCity(lang)}, ${hotel.getCountry(lang)}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.favorite_rounded,
                  color: Colors.white,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  '${favState.getFavoritesCount(hotel.hotelId)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations localizations) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_border_rounded,
                size: 48,
                color: Colors.redAccent,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              localizations.translate('no_favorites'),
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              localizations.translate('no_favorites_desc'),
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
