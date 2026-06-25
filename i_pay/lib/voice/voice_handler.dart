import 'package:flutter/material.dart';
import '../services/tts_service.dart';
import '../services/stt_service.dart';
import '../services/api_service.dart';
import '../models/voice_model.dart';
import '../app_state.dart';

// Screens
import '../screens/profile_screen.dart';
import '../screens/check_balance_screen.dart';
import '../screens/transaction_screen.dart';
import '../screens/transaction_history_screen.dart';
import '../screens/cibil_score_screen.dart';
import '../screens/loan_list_screen.dart';
import '../screens/bill_screen.dart';
import '../screens/recharge_screen.dart';
import '../screens/bank_transaction_screen.dart';
import '../screens/accounts_screen.dart';
import '../screens/analytics_screen.dart';

class VoiceHandler {
  VoiceHandler._();

  static const int _pinMaxAttempts = 3;

  /// 🔥 Main entry point
  static Future<void> handleRecognition({
    required BuildContext context,
    required VoiceResponse response,
  }) async {
    debugPrint("🎙 VoiceHandler received response");

    debugPrint("🎙 VoiceHandler received response");

// 1️⃣ Stop STT fully
    await STTService.stopListening();
    await Future.delayed(const Duration(milliseconds: 500));
    debugPrint("🗣️ BACKEND SPEECH => '${response.speech}'");


// 2️⃣ SPEAK FIRST (NO NAVIGATION YET)
    if (response.speech.trim().isNotEmpty) {
      debugPrint("🗣️ TTS SPEAKING: ${response.speech}");

      await TTSService.speak(
        response.speech,
        language: "en-US",
      );

      // 🔥 REQUIRED: give Android time to finish audio
      await Future.delayed(const Duration(milliseconds: 1200));
    }

// 3️⃣ PIN FLOW
    if (response.navigate == "pin_page") {
      await _handlePinFlow(context, response);
      return;
    }

// 4️⃣ Resolve command
    final String? command =
    response.navigate?.isNotEmpty == true
        ? response.navigate
        : response.intent;

    if (command == null || command.isEmpty) {
      await TTSService.speak("Sorry, I did not understand.");
      return;
    }

// 5️⃣ NAVIGATE ONCE — AFTER TTS
    debugPrint("🧠 Navigating to: $command");
    await _navigate(context, command);

  }

    // ---------------------- PIN HANDLING ----------------------
  static Future<void> _handlePinFlow(BuildContext context, VoiceResponse response) async {
    final int? accountId = response.extra?["account_id"] as int?;
    final String? action = response.extra?["action"] as String?;

    if (accountId == null) {
      await TTSService.speak(
        "Account information is missing. Cannot proceed.",
        language: "en-US",
      );
      return;
    }

    for (int attempt = 1; attempt <= _pinMaxAttempts; attempt++) {
      await TTSService.speak("Please say your transaction PIN.", language: "en-US");

      final String? pin = await STTService.listenOnce();

      if (pin == null || pin.isEmpty) {
        await TTSService.speak(
          "I did not hear the PIN. Attempt $attempt of $_pinMaxAttempts.",
          language: "en-US",
        );
        if (attempt == _pinMaxAttempts) return;
        continue;
      }

      final VoiceResponse verifyResponse = await ApiService().verifyPin(
        accountId: accountId,
        pin: pin,
        action: action ?? "",
      );

      await TTSService.speak(verifyResponse.speech, language: "en-US");

      if (verifyResponse.navigate != null && context.mounted) {
        await _navigate(context, verifyResponse.navigate!);
      }

      break; // success
    }
  }

  // ---------------------- NAVIGATION ----------------------
  static Future<void> _navigate(BuildContext context, String command) async {
    final int? accountId = AppState().currentAccountId;

    if (accountId == null &&
        command != "add_account_page" &&
        command != "loan_page") {
      await TTSService.speak("Please select an account first.", language: "en-US");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select an account first")),
        );
      }
      return;
    }

    if (!context.mounted) return;
    debugPrint("🧠 Navigating to: $command");

    switch (command) {
      case "profile_page":
        _push(context, ProfileScreen());
        break;
      case "balance_page":
        _push(context, CheckBalanceScreen());
        break;
      case "transaction_page":
        _push(context, TransactionScreen());
        break;
      case "history_page":
        _push(context, TransactionHistoryScreen());
        break;
      case "cibil_page":
        _push(context, CibilScoreScreen());
        break;
      case "loan_page":
        _push(context, const LoanListScreen());
        break;
      case "bill_pay_page":
        _push(context, const BillsScreen());
        break;
      case "recharge_page":
        _push(context, const RechargeScreen());
        break;
      case "bank_transfer_page":
        _push(context, BankTransactionScreen());
        break;
      case "add_account_page":
        _push(context, const AccountScreen());
        break;
      case "analytics_page":
        _push(context, AnalyticsScreen());
        break;
      default:
        await TTSService.speak(
          "Sorry, I did not understand the command.",
          language: "en-US",
        );
        debugPrint("❌ Unknown command: $command");
    }
  }

  static void _push(BuildContext context, Widget page) {
    if (!context.mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => page),
    );
  }
}
