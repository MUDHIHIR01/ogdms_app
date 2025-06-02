
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:untitled1/home_screen.dart';

void main() => runApp(const ChangelogApp());

class ChangelogApp extends StatelessWidget {
const ChangelogApp({super.key});

@override
Widget build(BuildContext context) {
return MaterialApp(
title: 'Changelog',
theme: ThemeData(
primaryColor: const Color(0xFFDF0613),
fontFamily: 'Nunito',
scaffoldBackgroundColor: Colors.white,
elevatedButtonTheme: ElevatedButtonThemeData(
style: ElevatedButton.styleFrom(
backgroundColor: const Color(0xFFDF0613),
foregroundColor: Colors.white,
padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
textStyle: const TextStyle(fontSize: 12),
),
),
textTheme: const TextTheme(
bodyMedium: TextStyle(fontSize: 12, color: Colors.black87),
titleLarge: TextStyle(fontSize: 16, color: Color(0xFFDF0613)),
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
labelStyle: const TextStyle(fontSize: 12, color: Colors.grey),
),
),
home: const SplashScreen(),
);
}
}

class SplashScreen extends StatefulWidget {
const SplashScreen({super.key});

@override
_SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
@override
void initState() {
super.initState();
Future.delayed(const Duration(seconds: 2), () {
if (mounted) {
Navigator.pushReplacement(
context,
MaterialPageRoute(
builder: (context) => const HomeScreen(username: 'Guest'),
),
);
}
});
}

@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: Colors.white,
body: Center(
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
const Text(
'Changelog',
style: TextStyle(
fontFamily: 'Nunito',
fontSize: 18,
color: Color(0xFFDF0613),
),
),
const SizedBox(height: 12),
const SpinKitWave(color: Color(0xFFDF0613), size: 20),
],
),
),
);
}
}