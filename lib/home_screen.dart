import 'package:flutter/material.dart';
import 'package:untitled1/api_service.dart';
import 'package:untitled1/customers_tab.dart';
import 'package:untitled1/leads_tab.dart';
import 'package:untitled1/notifications_tab.dart';
import 'package:untitled1/profile_tab.dart';
import 'package:untitled1/tickets_tab.dart';
import 'package:untitled1/auth_screen.dart';

class HomeScreen extends StatelessWidget {
  final String username;
  const HomeScreen({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFDF0613);
    const backgroundColor = Color(0xFFF5F7FA);
    const cardColor = Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'Nunito',
          ),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      drawer: Drawer(
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
        ),
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    DrawerHeader(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [primaryColor, primaryColor.withOpacity(0.8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Welcome, $username',
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'Nunito',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Manage your tasks efficiently',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontFamily: 'Nunito',
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildDrawerItem(
                      icon: Icons.home,
                      title: 'Home',
                      onTap: () => Navigator.pop(context),
                      primaryColor: primaryColor,
                    ),
                    _buildDrawerItem(
                      icon: Icons.person,
                      title: 'Profile',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ProfileTab()),
                        );
                      },
                      primaryColor: primaryColor,
                    ),
                    _buildDrawerItem(
                      icon: Icons.confirmation_number,
                      title: 'Tickets',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const TicketsTab()),
                        );
                      },
                      primaryColor: primaryColor,
                    ),
                    _buildDrawerItem(
                      icon: Icons.people,
                      title: 'Customers',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const CustomersTab()),
                        );
                      },
                      primaryColor: primaryColor,
                    ),
                    _buildDrawerItem(
                      icon: Icons.leaderboard,
                      title: 'Leads',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LeadsTab()),
                        );
                      },
                      primaryColor: primaryColor,
                    ),
                    _buildDrawerItem(
                      icon: Icons.notifications,
                      title: 'Notifications',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const NotificationsTab()),
                        );
                      },
                      primaryColor: primaryColor,
                    ),
                    _buildDrawerItem(
                      icon: Icons.logout,
                      title: 'Logout',
                      onTap: () async {
                        try {
                          await ApiService.logout();
                          Navigator.pop(context);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const AuthScreen()),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e', style: const TextStyle(fontSize: 14))),
                          );
                        }
                      },
                      primaryColor: primaryColor,
                    ),
                  ],
                ),
              ),
              Container(
                height: 50,
                color: primaryColor,
                child: const Center(
                  child: Text(
                    'OGDMS v1.0',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Nunito',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome, $username',
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search tasks, customers, or leads...',
                    hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontFamily: 'Nunito',
                      fontSize: 12,
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Colors.white.withOpacity(0.8),
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Colors.white.withOpacity(0.8),
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Colors.white.withOpacity(0.8),
                        width: 1,
                      ),
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.white.withOpacity(0.8),
                      size: 20,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  ),
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Nunito',
                    fontSize: 12,
                  ),
                  cursorColor: Colors.white,
                  onChanged: (value) {
                    // Implement search functionality here
                  },
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return GridView.count(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 1.0,
                      children: [
                        _NavCard(
                          title: 'Profile',
                          icon: Icons.person,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ProfileTab()),
                          ),
                          primaryColor: primaryColor,
                          cardColor: cardColor,
                          cardHeight: constraints.maxHeight / 2 - 8,
                        ),
                        _NavCard(
                          title: 'Home',
                          icon: Icons.home,
                          onTap: () {},
                          primaryColor: primaryColor,
                          cardColor: cardColor,
                          cardHeight: constraints.maxHeight / 2 - 8,
                        ),
                        _NavCard(
                          title: 'Tickets',
                          icon: Icons.confirmation_number,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const TicketsTab()),
                          ),
                          primaryColor: primaryColor,
                          cardColor: cardColor,
                          cardHeight: constraints.maxHeight / 2 - 8,
                        ),
                        _NavCard(
                          title: 'Customers',
                          icon: Icons.people,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const CustomersTab()),
                          ),
                          primaryColor: primaryColor,
                          cardColor: cardColor,
                          cardHeight: constraints.maxHeight / 2 - 8,
                        ),
                        _NavCard(
                          title: 'Leads',
                          icon: Icons.leaderboard,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const LeadsTab()),
                          ),
                          primaryColor: primaryColor,
                          cardColor: cardColor,
                          cardHeight: constraints.maxHeight / 2 - 8,
                        ),
                        _NavCard(
                          title: 'Notifications',
                          icon: Icons.notifications,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const NotificationsTab()),
                          ),
                          primaryColor: primaryColor,
                          cardColor: cardColor,
                          cardHeight: constraints.maxHeight / 2 - 8,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required Color primaryColor,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: primaryColor,
        size: 20,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Nunito',
          fontSize: 14,
          color: Colors.black,
          fontWeight: FontWeight.normal, // Set to normal to remove bold
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      tileColor: Colors.transparent,
      hoverColor: primaryColor.withOpacity(0.3),
      dense: true,
    );
  }
}

class _NavCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final Color primaryColor;
  final Color cardColor;
  final double cardHeight;

  const _NavCard({
    required this.title,
    required this.icon,
    required this.onTap,
    required this.primaryColor,
    required this.cardColor,
    required this.cardHeight,
  });

  @override
  Widget build(BuildContext context) {
    final iconSize = cardHeight * 0.225;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      color: cardColor,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        splashColor: primaryColor.withOpacity(0.2),
        highlightColor: primaryColor.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: primaryColor,
                size: iconSize,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 12,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}