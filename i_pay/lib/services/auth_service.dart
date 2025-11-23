import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl = "http://127.0.0.1:8000";
  Future<bool> login(String emailOrMobile, String password) async {
    final url = Uri.parse("$baseUrl/auth/login");
    final response = await http.post(url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email_or_mobile": emailOrMobile, "password": password}));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data["access_token"];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("auth_token", token);
      return true;
    }
    return false;
  }

  Future<bool> signup(String name, String email, String mobile, String password, String transactionPin) async {
    final url = Uri.parse("$baseUrl/auth/signup");
    final response = await http.post(url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": name,
          "email": email,
          "mobile": mobile,
          "password": password,
          "transaction_pin": transactionPin
        }));
    return response.statusCode == 200;
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("auth_token");
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("auth_token");
  }
}
