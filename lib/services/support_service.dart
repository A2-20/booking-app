import 'api_service.dart';
import '../models/support_request_model.dart';

class SupportService {
  static Future<List<SupportRequestModel>> getSupportRequests() async {
    try {
      final response = await ApiService.get('/support');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => SupportRequestModel.fromJson(json)).toList();
      }
    } catch (e) {
      // Error handled by ApiService
    }
    return [];
  }

  static Future<bool> sendSupportRequest({
    required String subject,
    required String message,
    String priority = 'medium',
  }) async {
    try {
      final response = await ApiService.post(
        '/support',
        data: {'subject': subject, 'message': message, 'priority': priority},
      );
      return response.statusCode == 201;
    } catch (e) {
      // Error handled by ApiService
      return false;
    }
  }
}
