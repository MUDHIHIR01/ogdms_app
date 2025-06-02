
import 'package:flutter/material.dart';
import 'package:untitled1/home_screen.dart';

class NotificationsTab extends StatelessWidget {
const NotificationsTab({super.key});

@override
Widget build(BuildContext context) {
const demoNotifications = [
{'message': 'New ticket assigned', 'date': '2025-06-02'},
{'message': 'Profile updated', 'date': '2025-06-01'},
];

return Scaffold(
backgroundColor: Colors.white,
appBar: AppBar(
title: const Text('Notifications', style: TextStyle(color: Colors.white, fontSize: 16)),
backgroundColor: const Color(0xFFDF0613),
),
body: Column(
children: [
Expanded(
child: demoNotifications.isEmpty
? const Center(
child: Text('No notifications',
style: TextStyle(fontFamily: 'Nunito', fontSize: 14)))
    : ListView.builder(
padding: const EdgeInsets.all(12),
itemCount: demoNotifications.length,
itemBuilder: (context, index) {
final notification = demoNotifications[index];
return Card(
elevation: 2,
margin: const EdgeInsets.only(bottom: 8),
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
child: ListTile(
leading:
const Icon(Icons.notifications, color: Color(0xFFDF0613), size: 16),
title: Text(notification['message']!,
style: const TextStyle(fontFamily: 'Nunito', fontSize: 12)),
subtitle: Text(notification['date']!,
style: const TextStyle(fontFamily: 'Nunito', fontSize: 12)),
),
);
},
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