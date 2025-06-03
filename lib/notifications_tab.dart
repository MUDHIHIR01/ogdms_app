import 'package:flutter/material.dart';
import 'package:untitled1/api_service.dart';
import 'package:untitled1/home_screen.dart';

class NotificationsTab extends StatefulWidget {
  const NotificationsTab({super.key});

  @override
  _NotificationsTabState createState() => _NotificationsTabState();
}

class _NotificationsTabState extends State<NotificationsTab> {
  late Future<List<Map<String, dynamic>>> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    _notificationsFuture = ApiService.getNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Nunito')),
        backgroundColor: const Color(0xFFDF0613),
        // Add this line to make the back arrow (and other AppBar icons) white
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _notificationsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading notifications', style: TextStyle(fontFamily: 'Nunito', fontSize: 14)));
                }
                final notifications = snapshot.data ?? [];
                if (notifications.isEmpty) {
                  return const Center(
                    child: Text('No notifications', style: TextStyle(fontFamily: 'Nunito', fontSize: 14)),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return Card(
                      elevation: 1,
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      child: ListTile(
                        leading: const Icon(Icons.notifications, color: Color(0xFFDF0613), size: 20),
                        title: Text(
                          notification['message'] ?? 'Unknown',
                          style: const TextStyle(fontFamily: 'Nunito', fontSize: 14),
                        ),
                        subtitle: Text(
                          notification['date'] ?? '',
                          style: const TextStyle(fontFamily: 'Nunito', fontSize: 12),
                        ),
                      ),
                    );
                  },
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
                minimumSize: const Size(double.infinity, 48),
                backgroundColor: Colors.grey[300],
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Back to Home', style: TextStyle(fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }
}