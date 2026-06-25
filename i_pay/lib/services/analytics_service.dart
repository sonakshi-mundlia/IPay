import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class AnalyticsService {
  final String baseUrl = "http://10.0.2.2:8000/analytics";
  final ApiService apiService = ApiService();


  Future<Map<String, dynamic>> fetchAnalytics() async {
    final token = await apiService.getToken();
    final url = Uri.parse(baseUrl);

    try {
      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data as Map<String, dynamic>;
      } else {
        return {};
      }
    } catch (e) {
      print("Error fetching analytics: $e");
      return {};
    }
  }
}
