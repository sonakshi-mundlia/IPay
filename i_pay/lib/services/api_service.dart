import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  int? currentUserId;
  static const String baseUrl = "http://10.0.2.2:8000";
  String? _authToken;

  Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  Future<bool> login(String emailOrMobile, String password) async {
    final url = Uri.parse('$baseUrl/auth/login');
    final resp = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email_or_mobile': emailOrMobile, 'password': password}),
    );

    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      _authToken = data['token'];
      return true;
    }
    return false;
  }

  Future<bool> register(String name, String email, String mobile, String password, String pin) async {
    final url = Uri.parse('$baseUrl/auth/register');
    final resp = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'mobile': mobile,
        'password': password,
        'transaction_pin': pin,
      }),
    );
    return resp.statusCode == 201 || resp.statusCode == 200;
  }

  Future<Map<String, dynamic>> getProfile() async {
    final url = Uri.parse('$baseUrl/profile/');
    final resp = await http.get(url, headers: _headers);
    return jsonDecode(resp.body);
  }

  Future<List<dynamic>> getAccounts() async {
    final url = Uri.parse('$baseUrl/accounts/');
    final resp = await http.get(url, headers: _headers);
    return jsonDecode(resp.body);
  }

  Future<bool> addAccount({
    required String bankName,
    required String vpa,
    required String accountNumber,
    required String ifsc,
    String? email,
    String? mobile,
  }) async {
    final url = Uri.parse('$baseUrl/accounts/add');
    final resp = await http.post(
      url,
      headers: _headers,
      body: jsonEncode({
        'bank_name': bankName,
        'vpa_id': vpa,
        'account_number': accountNumber,
        'ifsc_code': ifsc,
        'email': email ?? "",
        'mobile': mobile ?? "",
        'balance': 0.0,
      }),
    );

    if (resp.statusCode == 200 || resp.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  }


  Future<Map<String, dynamic>> sendTransaction(int fromId, int toId, double amount, String pin, {String category = "transfer"}) async {
    final url = Uri.parse('$baseUrl/transaction');
    final resp = await http.post(
      url,
      headers: _headers,
      body: jsonEncode({
        "from_account_id": fromId,
        "to_account_id": toId,
        "amount": amount,
        "pin": pin,
        "category": category,
      }),
    );
    return jsonDecode(resp.body);
  }

  Future<List<dynamic>> getTransactionHistory({int limit = 10}) async {
    final url = Uri.parse('$baseUrl/transaction/history?limit=$limit');
    final resp = await http.get(url, headers: _headers);
    return jsonDecode(resp.body);
  }

  Future<Map<String, dynamic>> getAnalytics() async {
    final url = Uri.parse('$baseUrl/analytics/');
    final resp = await http.get(url, headers: _headers);
    return jsonDecode(resp.body);
  }

  Future<List<dynamic>> getFAQs() async {
    final url = Uri.parse('$baseUrl/help/faqs');
    final resp = await http.get(url, headers: _headers);
    return jsonDecode(resp.body);
  }

  Future<String> askHelpQuestion(String question) async {
    final url = Uri.parse('$baseUrl/help/ask');
    final resp = await http.post(url, headers: _headers, body: jsonEncode({'question': question}));
    final data = jsonDecode(resp.body);
    return data['answer'] ?? "No answer found.";
  }

  Future<String> processVoiceCommand(String text) async {
    final url = Uri.parse('$baseUrl/nlp');
    final resp = await http.post(
      url,
      headers: _headers,
      body: jsonEncode({'text': text}),
    );

    final data = jsonDecode(resp.body);

    if (data == null || data['message'] == null) {
      return "Could not process voice command.";
    }

    return data['message'];
  }


}
