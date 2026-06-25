import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

// Core
import 'services/api_service.dart';
import 'app_state.dart';

// Localization
import 'core/languages/app_languages.dart';
import 'core/languages/app_localizations_delegate.dart';
import 'core/languages/language_provider.dart';

// Screens
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // API service
  final apiService = ApiService();
  await apiService.init();

  // App state
  await AppState().load(apiService);

  // Language provider
  final languageProvider = LanguageProvider();
  await languageProvider.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: languageProvider),
        Provider<ApiService>.value(value: apiService),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();

    debugPrint('🌍 App rebuild → locale = ${languageProvider.locale.languageCode}');

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AI Voice Banking',

      // 🔹 Current locale (runtime switch)
      locale: languageProvider.locale,

      // 🔹 Supported locales
      supportedLocales: AppLanguages.supportedLocales,

      // 🔹 Delegates (remove const)
      localizationsDelegates: [
        AppLocalizationDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      theme: ThemeData(
        primaryColor: Colors.white,
        useMaterial3: true,
      ),

      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool? loggedIn;

  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    final apiService = context.read<ApiService>();
    final token = await apiService.getToken();

    if (!mounted) return;

    setState(() {
      loggedIn = token != null;
    });
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Safe: don't use AppLocalizations here in initState
    if (loggedIn == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return loggedIn! ? const HomeScreen() : const LoginScreen();
  }
}
