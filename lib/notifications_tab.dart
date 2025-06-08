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
  List<Map<String, dynamic>> _filteredNotifications = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _notificationsFuture = _fetchNotifications();
    _searchController.addListener(_filterNotifications);
  }

  Future<List<Map<String, dynamic>>> _fetchNotifications() async {
    try {
      final notifications = await ApiService.getNotifications();
      _filteredNotifications = notifications; // Initialize filtered list
      return notifications;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load notifications: $e',
                style: const TextStyle(fontFamily: 'Nunito', fontSize: 14)),
          ),
        );
      }
      return [];
    }
  }

  void _refreshNotifications() {
    setState(() {
      _notificationsFuture = _fetchNotifications();
    });
  }

  void _filterNotifications() {
    _notificationsFuture.then((notifications) {
      final query = _searchController.text.toLowerCase();
      setState(() {
        _filteredNotifications = notifications.where((notification) {
          final message = notification['message']?.toLowerCase() ?? '';
          final date = notification['date']?.toLowerCase() ?? '';
          return message.contains(query) || date.contains(query);
        }).toList();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFDF0613);
    const backgroundColor = Colors.white;
    const cardColor = Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontFamily: 'Nunito',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by message or date',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: primaryColor, width: 1),
                ),
                prefixIcon: const Icon(Icons.search, color: primaryColor),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear, color: primaryColor),
                  onPressed: () {
                    _searchController.clear();
                    _filterNotifications();
                  },
                )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _notificationsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: primaryColor));
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Error loading notifications',
                          style: TextStyle(fontFamily: 'Nunito', fontSize: 14),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _refreshNotifications,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text(
                            'Retry',
                            style: TextStyle(fontFamily: 'Nunito', fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                final notifications = snapshot.data ?? [];
                if (_filteredNotifications.isEmpty && _searchController.text.isNotEmpty) {
                  return const Center(
                    child: Text(
                      'No matching notifications',
                      style: TextStyle(fontFamily: 'Nunito', fontSize: 14),
                    ),
                  );
                }
                if (_filteredNotifications.isEmpty && notifications.isEmpty) {
                  return const Center(
                    child: Text(
                      'No notifications available',
                      style: TextStyle(fontFamily: 'Nunito', fontSize: 14),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _filteredNotifications.length,
                  itemBuilder: (context, index) {
                    final notification = _filteredNotifications[index];
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      color: cardColor,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        leading: const Icon(
                          Icons.notifications,
                          color: primaryColor,
                          size: 24,
                        ),
                        title: Text(
                          notification['message'] ?? 'Unknown',
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        subtitle: Text(
                          notification['date'] ?? 'No date',
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 14,
                            color: Colors.black54,
                          ),
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
                MaterialPageRoute(builder: (context) => const HomeScreen(username: 'Guest', role: '',)),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                backgroundColor: Colors.grey[300],
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'Back to Home',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}