
import 'package:flutter/material.dart';
import 'package:untitled1/home_screen.dart';

class LeadsTab extends StatelessWidget {
const LeadsTab({super.key});

@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: Colors.white,
appBar: AppBar(
title: const Text('Leads', style: TextStyle(color: Colors.white, fontSize: 16)),
backgroundColor: const Color(0xFFDF0613),
),
body: Column(
children: [
const Expanded(
child: Center(
child: Text(
'Leads Page',
style: TextStyle(fontFamily: 'Nunito', fontSize: 14, color: Color(0xFFDF0613)),
),
),
),
Padding(
padding: const EdgeInsets.all(12),
child: ElevatedButton(
onPressed: () => Navigator.pushReplacement(
context,
MaterialPageRoute(
builder: (context) => const HomeScreen(username: 'Guest'),
),
),
style: ElevatedButton.styleFrom(
backgroundColor: Colors.grey[300],
foregroundColor: Colors.black,
minimumSize: const Size(double.infinity, 36),
),
child: const Text('Back to Home'),
),
),
],
),
);
}
}