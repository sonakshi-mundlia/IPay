import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recent_contacts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../models/cibil_score_model.dart';
import '../models/bank_account_model.dart';
import '../models/voice_model.dart';
import '../app_state.dart';

  class ApiService {
    static const String baseUrl = "http://127.0.0.1:8000";
    String? _authToken;

    static final ApiService _instance = ApiService._internal();
    factory ApiService() => _instance;
    ApiService._internal();

    void _log(Object? message) {
      debugPrint(message.toString(), wrapWidth: 1024);
    }


    Future<void> init() async {
      final prefs = await SharedPreferences.getInstance();
      _authToken = prefs.getString("auth_token");
      _log("🟢 TOKEN LOADED at init => $_authToken");
    }

    // Automatically ensure token is loaded before any API call
    Future<void> _ensureTokenLoaded() async {
      if (_authToken == null) {
        final prefs = await SharedPreferences.getInstance();
        _authToken = prefs.getString("auth_token");
        _log("🟢 TOKEN LOADED from _ensureTokenLoaded => $_authToken");
      }
    }

    Future<String?> getToken() async {
      await _ensureTokenLoaded();
      return _authToken;
    }

  Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  Future<Map<String, dynamic>?> login({
    String? email,
    int? mobile,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/auth/login');
    print("API CALL URL => $url");

    final body = {
      "email": email,
      "mobile": mobile,
      "password": password,
    };

    // Remove nulls
    body.removeWhere((key, value) => value == null);

    final resp = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      _authToken = data['access_token'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', _authToken!);

      return data;

    }

    return null;
  }

    Future<void> clearToken() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove("auth_token");
      _authToken = null;
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
    await _ensureTokenLoaded();
    final url = Uri.parse('$baseUrl/profile/');
    final resp = await http.get(url, headers: _headers);

    if (resp.statusCode == 200) {
      return jsonDecode(resp.body);
    } else {
      throw Exception(
          'Failed to fetch profile. Status code: ${resp.statusCode}, Body: ${resp.body}');
    }
  }

  Future<List<Map<String, dynamic>>> getAccounts() async {
    await _ensureTokenLoaded();
    final url = Uri.parse('$baseUrl/accounts/');
    final resp = await http.get(url, headers: _headers);

    if (resp.statusCode == 200) {
      final List<dynamic> data = jsonDecode(resp.body);
      return data.map((item) => item as Map<String, dynamic>).toList();
    } else {
      throw Exception('Failed to fetch accounts');
    }
  }

    Future<bool> setActiveAccount(int accountId) async {
      final response = await http.post(
        Uri.parse("$baseUrl/accounts/set-active/$accountId"),
        headers: _headers,
        body: jsonEncode({'account_id': accountId.toString()}),
      );

      return response.statusCode == 200;
    }


    Future<VoiceResponse> verifyPin({
      required int accountId,
      required String pin,
      required String action,
    }) async {
      final url = Uri.parse("$baseUrl/pin/verify");

      final resp = await http.post(
        url,
        headers: _headers,
        body: jsonEncode({
          "account_id": accountId,
          "transaction_pin": pin,
          "action": action,
        }),
      );

      if (resp.statusCode != 200) {
        final error = jsonDecode(resp.body);
        throw Exception(error["detail"] ?? "PIN verification failed");
      }

      return VoiceResponse.fromJson(jsonDecode(resp.body));
    }

    Future<Map<String, dynamic>> checkBalance({
    required int accountId,
    required String transactionPin,
  }) async {
    final url = Uri.parse("$baseUrl/transaction/check-balance");
    await _ensureTokenLoaded();
    print("USING TOKEN => $_authToken");

    final body = jsonEncode({
      "account_id": accountId,
      "transaction_pin": transactionPin,
    });

    final resp = await http.post(
      url,
      headers: _headers,
      body: body,
    );

    if (resp.statusCode == 200) {
      return jsonDecode(resp.body);
    } else {
      print(resp.body);
      final error = jsonDecode(resp.body);
      throw Exception(error["detail"] ?? "Failed to check balance");
    }
  }

  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    try {
      if (query.trim().length < 3) return [];

      final url = Uri.parse("$baseUrl/users/search").replace(
        queryParameters: {
          'q': query,
        },
      );

      final response = await http.get(
        url,
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        return data.map<Map<String, dynamic>>((u) => {
          "id": u["id"],
          "name": u["name"],
          "mobile": u["mobile"],
        }).toList();
      } else {
        debugPrint("Search failed: ${response.body}");
        return [];
      }
    } catch (e) {
      debugPrint("Search error: $e");
      return [];
    }
  }

  Future<int?> addAccount({
    required String bankName,
    required String vpa,
    required String accountNumber,
    required String ifsc,
    String? pin,
    double? balance,
    String? email,
    String? mobile,
  }) async {
    final url = Uri.parse('$baseUrl/accounts/add-account');
    final body = {
      'bank_name': bankName,
      'vpa_id': vpa,
      'account_number': accountNumber,
      'ifsc_code': ifsc,
      'balance': balance,
      'email': email ?? "",
      'mobile': mobile ?? "",
      'transaction_pin': pin,
    };
    final resp = await http.post(
      url,
      headers: _headers,
      body: jsonEncode(body),
    );

    if (resp.statusCode == 200 || resp.statusCode == 201) {
      final data = jsonDecode(resp.body);
      final accountId = data['account_id'];
    }
    return null;
  }
  Future<int> getAccountCount() async {
    final url = Uri.parse('$baseUrl/accounts');
    final resp = await http.get(url, headers: _headers);

    if (resp.statusCode == 200) {
      final List data = jsonDecode(resp.body);
      return data.length;
    }
    throw Exception("Failed to fetch accounts");
  }

  Future<bool> deleteAccount(int accountId) async {
    final url = Uri.parse('$baseUrl/accounts/delete-account/$accountId');
    final resp = await http.delete(url, headers: _headers);

    if (resp.statusCode == 200) {
      debugPrint("✅ Account $accountId deleted successfully");
      return true;
    } else {
      debugPrint(
          "❌ Failed to delete account $accountId. Status: ${resp.statusCode}");
      return false;
    }
  }

    Future<List<BankAccount>> getUserBankAccounts({
      required int excludeAccountId,
    }) async {
      final url = Uri.parse("$baseUrl/accounts/available/").replace(
        queryParameters: {
          'exclude_account_id': excludeAccountId.toString(),
        },
      );
      await _ensureTokenLoaded();

      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((e) => BankAccount.fromJson(e)).toList();
      } else {
        throw Exception("Failed to load accounts");
      }
    }

    // Send transaction from a specific account
  Future<Map<String, dynamic>> sendTransaction({
    required int fromAccountId,
    required int toAccountId,
    required double amount,
    required String pin,
    String category = "transfer",
  }) async {
    final url = Uri.parse('$baseUrl/transaction/send');
    final body = {
      "from_account_id": fromAccountId,
      "to_account_id": toAccountId,
      "amount": amount,
      "transaction_pin": pin,
      "category": category,
    };
    print("Sending transaction body: $body");

    final resp = await http.post(
      url,
      headers: _headers,
      body: jsonEncode(body),
    );

    if (resp.statusCode == 200) {
      return jsonDecode(resp.body);
    } else {
      throw Exception("Transaction failed: ${resp.body}");
    }
  }

// Get CIBIL score for a specific account
  Future<CibilModel> getCibilScore(int accountId) async {
    final res = await http.get(
      Uri.parse("$baseUrl/cibil/ai-score").replace(
        queryParameters: {
          'account_id': accountId.toString(),
        },
      ),
      headers: _headers,
    );

    if (res.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(res.body);
      return CibilModel.fromJson(json);
    } else {
      throw Exception("Failed to fetch CIBIL score: ${res.body}");
    }
  }

  Future<List<dynamic>> getTransactionHistory({
    required int accountId,
    int limit = 10,
  }) async {
    final url = Uri.parse('$baseUrl/transaction/history').replace(
      queryParameters: {
      'account_id': accountId.toString(),
      'limit': limit.toString(),
      },
    );
    final resp = await http.get(url, headers: _headers);

    if (resp.statusCode == 200) {
      return jsonDecode(resp.body);
    } else {
      throw Exception("Failed to fetch transaction history: ${resp.body}");
    }
  }


    Future<Map<String, dynamic>> getAnalytics(int accountId, {String? startDate, String? endDate}) async {
      final url = Uri.parse('$baseUrl/analytics/').replace(
        queryParameters: {
          'account_id': accountId.toString(),
          if (startDate != null) 'start_date': startDate,
          if (endDate != null) 'end_date': endDate,
        },
      );

      final resp = await http.get(url, headers: _headers);

      if (resp.statusCode == 200) {
        return jsonDecode(resp.body);
      } else {
        throw Exception('Failed to load analytics: ${resp.statusCode}');
      }
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

  Future<List<RecentContact>> getRecentContacts(int accountId) async {
    final url = Uri.parse("$baseUrl/transaction/recent/$accountId");

    final response = await http.get(url, headers: _headers);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((x) => RecentContact.fromJson(x)).toList();
    } else {
      throw Exception("Failed to load contacts");
    }
  }
    Future<VoiceResponse> processVoiceCommand(String text) async {
      final url = Uri.parse("$baseUrl/nlp");

      final resp = await http.post(
        url,
        headers: _headers,
        body: jsonEncode({"text": text,"account_id": AppState().currentAccountId,
          "lang": "en"}),
      );

      if (resp.statusCode != 200) {
        throw Exception("NLP failed: ${resp.statusCode}");
      }

      return VoiceResponse.fromJson(jsonDecode(resp.body));
    }

  }
