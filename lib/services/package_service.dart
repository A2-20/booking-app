import '../models/package_model.dart';
import 'api_service.dart';

class PackageService {
  // Get all packages
  static Future<List<PackageModel>> getAllPackages() async {
    try {
      final response = await ApiService.get('/packages');
      if (response.statusCode == 200) {
        return (response.data as List)
            .map((json) => PackageModel.fromJson(json))
            .toList();
      }
    } catch (e) {
      print('Fetch packages error: $e');
    }
    return [];
  }

  // Get package by ID
  static Future<PackageModel?> getPackageById(String packageId) async {
    final packages = await getAllPackages();
    try {
      return packages.firstWhere((p) => p.packageId == packageId);
    } catch (e) {
      return null;
    }
  }

  // Initialize packages
  static Future<void> initializePackages() async {
    await getAllPackages();
  }
}
