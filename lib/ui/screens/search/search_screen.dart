import 'package:flutter/material.dart';
import '../../../localization/app_localizations.dart';
import '../../../services/hotel_service.dart';
import '../../../services/flight_service.dart';
import '../../../services/package_service.dart';
import '../../../models/hotel_model.dart';
import '../../../models/flight_model.dart';
import '../../../models/package_model.dart';
import '../../components/cards/hotel_card.dart';
import '../flight_details/flight_details_screen.dart';
import '../package_details/package_details_screen.dart';
import '../../../theme/app_theme.dart';
import '../../widgets/currency_icon.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'hotels';
  List<HotelModel> _hotels = [];
  List<FlightModel> _flights = [];
  List<PackageModel> _packages = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _performSearch();
    });
  }

  Future<void> _performSearch() async {
    setState(() {
      _isLoading = true;
    });

    final query = _searchController.text.trim().toLowerCase();

    if (_selectedCategory == 'hotels') {
      final hotels = await HotelService.searchHotels(city: query);
      setState(() {
        _hotels = hotels;
      });
    } else if (_selectedCategory == 'flights') {
      final flights = await FlightService.searchFlights(departureCity: query);
      setState(() {
        _flights = flights;
      });
    } else {
      final packages = await PackageService.getAllPackages();
      setState(() {
        _packages = packages;
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text(localizations.translate('search')),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onSubmitted: (_) => _performSearch(),
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: localizations.translate('search'),
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _performSearch,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: Text(
                      localizations.translate('hotels'),
                      style: TextStyle(
                        color: _selectedCategory == 'hotels'
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    selected: _selectedCategory == 'hotels',
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = 'hotels';
                      });
                      _performSearch();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ChoiceChip(
                    label: Text(
                      localizations.translate('flights'),
                      style: TextStyle(
                        color: _selectedCategory == 'flights'
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    selected: _selectedCategory == 'flights',
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = 'flights';
                      });
                      _performSearch();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ChoiceChip(
                    label: Text(
                      localizations.translate('packages'),
                      style: TextStyle(
                        color: _selectedCategory == 'packages'
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    selected: _selectedCategory == 'packages',
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = 'packages';
                      });
                      _performSearch();
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildResults(localizations),
          ),
        ],
      ),
    );
  }

  Widget _buildResults(AppLocalizations localizations) {
    if (_selectedCategory == 'hotels') {
      if (_hotels.isEmpty) {
        return Center(child: Text(localizations.translate('no_results')));
      }
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _hotels.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: HotelCard(hotel: _hotels[index]),
          );
        },
      );
    } else if (_selectedCategory == 'flights') {
      if (_flights.isEmpty) {
        return Center(child: Text(localizations.translate('no_results')));
      }
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _flights.length,
        itemBuilder: (context, index) {
          final flight = _flights[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: flight.images.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
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
                '${flight.getAirline(localizations.locale.languageCode)} - ${flight.departureTime}',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${flight.price}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const CurrencyIcon(size: 14, color: AppTheme.primaryColor),
                ],
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => FlightDetailsScreen(flight: flight),
                  ),
                );
              },
            ),
          );
        },
      );
    } else {
      if (_packages.isEmpty) {
        return Center(child: Text(localizations.translate('no_results')));
      }
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _packages.length,
        itemBuilder: (context, index) {
          final package = _packages[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: package.images.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
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
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${package.finalPrice}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const CurrencyIcon(size: 14, color: AppTheme.primaryColor),
                ],
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        PackageDetailsScreen(package: package),
                  ),
                );
              },
            ),
          );
        },
      );
    }
  }
}
