class AppConfig {
  static const String appName = 'Booking App';
  static const String appVersion = '1.0.0';

  // API Configuration
  // For Android Emulator: 10.0.2.2
  // For iOS Simulator: 127.0.0.1
  // For Physical Device: Use your computer's local IP (e.g., 192.168.1.10)
  static const String apiBaseIp = '127.0.0.1';
  static const String apiPort = '8000';
  static const String apiUrl = 'http://$apiBaseIp:$apiPort/api';

  // Default language
  static const String defaultLanguage = 'ar';

  // Supported languages
  static const List<String> supportedLanguages = ['ar', 'en'];

  // Currency
  static const String currency = 'SAR';
  static const String currencySvgPath = 'assets/images/sar_symbol.svg';
  static const String stripePublishableKey =
      'pk_test_51T7ZDa0BTgCCbID8hgbd6GNI2IFt17qVDhF87HtRGOhc5ITNaogNuQSW9PqbYZOLDKcQMFoIilUPFhTDNUBoC6Lx00emSdgcP6'; // Replace with actual key
}
