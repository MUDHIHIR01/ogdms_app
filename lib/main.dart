import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:app_links/app_links.dart';
import 'auth_screen.dart';
import 'reset_password_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget _initialScreen = const SplashScreen();
  final _appLinks = AppLinks();

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  void _initDeepLinks() async {
    try {
      print('Initializing deep links...');
      // Handle initial deep link
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null && mounted) {
        print('Initial deep link: $initialUri');
        _handleDeepLink(initialUri);
      }

      // Handle incoming deep links
      _appLinks.uriLinkStream.listen((uri) {
        if (uri != null && mounted) {
          print('Received deep link: $uri');
          _handleDeepLink(uri);
        }
      }, onError: (err) {
        print('Deep link error: $err');
      });
    } catch (e) {
      print('Deep link init error: $e');
    }
  }

  void _handleDeepLink(Uri uri) {
    if (uri.path == '/reset' && uri.queryParameters['email'] != null && uri.queryParameters['token'] != null) {
      print('Valid reset link: ${uri.queryParameters}');
      setState(() {
        _initialScreen = ResetPasswordScreen(
          email: uri.queryParameters['email']!,
          token: uri.queryParameters['token']!,
        );
      });
    } else {
      print('Invalid reset link: $uri');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OGDMS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFFDF0613),
        fontFamily: 'Nunito',
        scaffoldBackgroundColor: Colors.white,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFDF0613),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFDF0613)),
          ),
        ),
      ),
      home: _initialScreen,
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        print('Splash done, to AuthScreen');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AuthScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFDF0613),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'OGDMS',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            SpinKitWave(color: Colors.white, size: 24),
          ],
        ),
      ),
    );
  }
}