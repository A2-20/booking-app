import 'package:flutter/foundation.dart';
import '../models/hotel_model.dart';
import '../models/flight_model.dart';
import '../models/package_model.dart';

class SearchState extends ChangeNotifier {
  List<HotelModel> _hotels = [];
  List<FlightModel> _flights = [];
  List<PackageModel> _packages = [];
  bool _isLoading = false;
  String _searchQuery = '';

  List<HotelModel> get hotels => _hotels;
  List<FlightModel> get flights => _flights;
  List<PackageModel> get packages => _packages;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setHotels(List<HotelModel> hotels) {
    _hotels = hotels;
    notifyListeners();
  }

  void setFlights(List<FlightModel> flights) {
    _flights = flights;
    notifyListeners();
  }

  void setPackages(List<PackageModel> packages) {
    _packages = packages;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearResults() {
    _hotels = [];
    _flights = [];
    _packages = [];
    _searchQuery = '';
    notifyListeners();
  }
}
