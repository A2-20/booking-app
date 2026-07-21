import '../models/user_model.dart';
import '../storage/local_storage_manager.dart';
import 'api_service.dart';

class AuthService {
  static UserModel? _currentUser;

  static UserModel? get currentUser => _currentUser;

  // Login
  static Future<UserModel?> login(String email, String password) async {
    try {
      final response = await ApiService.post(
        '/login',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        final token = response.data['token'] ?? response.data['access_token'];
        final userData = response.data['user'];
        _currentUser = UserModel.fromJson(userData);

        await LocalStorageManager.saveToken(token);
        await LocalStorageManager.saveUser(_currentUser!);
        await LocalStorageManager.setCurrentUserId(_currentUser!.userId);

        return _currentUser;
      }
    } catch (e) {
      print('Login error: $e');
    }
    return null;
  }

  static Future<UserModel?> register({
    required String fullName,
    required String email,
    required String password,
    required String phone,
    required String country,
  }) async {
    try {
      final response = await ApiService.post(
        '/register',
        data: {
          'name': fullName,
          'email': email,
          'password': password,
          'phone': phone,
          'country': country,
        },
      );

      if (response.statusCode == 200) {
        final token = response.data['token'] ?? response.data['access_token'];
        final userData = response.data['user'];
        _currentUser = UserModel.fromJson(userData);

        await LocalStorageManager.saveToken(token);
        await LocalStorageManager.saveUser(_currentUser!);
        await LocalStorageManager.setCurrentUserId(_currentUser!.userId);

        return _currentUser;
      }
    } catch (e) {
      print('Register error: $e');
    }
    return null;
  }

  // Logout
  static Future<void> logout() async {
    try {
      await ApiService.post('/logout');
    } catch (e) {
      print('Logout error: $e');
    } finally {
      _currentUser = null;
      await LocalStorageManager.clearCurrentUser();
      await LocalStorageManager.clearToken();
    }
  }

  // Get current user from storage/API
  static Future<UserModel?> getCurrentUserFromStorage() async {
    // Try to load from local storage first for immediate UI update
    _currentUser = await LocalStorageManager.getUser();

    final token = await LocalStorageManager.getToken();
    if (token == null) return _currentUser;

    try {
      final response = await ApiService.get('/user');
      if (response.statusCode == 200) {
        _currentUser = UserModel.fromJson(response.data);
        await LocalStorageManager.saveUser(_currentUser!);
        return _currentUser;
      }
    } catch (e) {
      print('Error fetching profile: $e');
      // If we have a local user, keep it even if API fails
      if (_currentUser != null) return _currentUser;

      // Only logout if it's a 401/Unauthorized or we have no local cache
      // For connection errors, we want to stay "logged in" offline.
    }
    return _currentUser;
  }

  // Update user
  static Future<UserModel?> updateUser(UserModel updatedUser) async {
    try {
      final response = await ApiService.put(
        '/user',
        data: {
          'name': updatedUser.fullName,
          'email': updatedUser.email,
          // Password update not handled here for simplicity in this flow
        },
      );

      if (response.statusCode == 200) {
        _currentUser = UserModel.fromJson(response.data);
        return _currentUser;
      }
    } catch (e) {
      print('Update user error: $e');
    }
    return null;
  }

  // Initialize users (placeholder)
  static Future<void> initializeUsers() async {
    // Logic to initialize users if needed
  }
}
