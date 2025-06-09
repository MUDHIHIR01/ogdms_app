import 'dart:async';
import 'package:flutter/material.dart';
import 'package:untitled1/api_service.dart';
import 'package:untitled1/customers_tab.dart';
import 'package:untitled1/leads_tab.dart';
import 'package:untitled1/notifications_tab.dart';
import 'package:untitled1/profile_tab.dart';
import 'package:untitled1/tickets_tab.dart';
import 'package:untitled1/auth_screen.dart';

class HomeScreen extends StatefulWidget {
  final String username;
  final String role;
  const HomeScreen({super.key, required this.username, required this.role});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Timer? _debounce;

  // Base list of navigation items for both drawer and dashboard cards
  final List<Map<String, dynamic>> _baseNavItems = [
    {'title': 'Profile', 'icon': Icons.person, 'route': const ProfileTab()},
    {'title': 'Tickets', 'icon': Icons.confirmation_number, 'route': const TicketsTab()},
    {
      'title': 'Customers',
      'icon': Icons.people,
      'route': CustomersTab(role: ''), // Placeholder; role is set dynamically
    },
    {'title': 'Leads', 'icon': Icons.leaderboard, 'route': const LeadsTab()},
    {'title': 'Notifications', 'icon': Icons.notifications, 'route': const NotificationsTab()},
  ];

  // Drawer navigation items, filtered by role
  List<Map<String, dynamic>> get _drawerNavItems {
    return _baseNavItems
        .where((item) {
          if (widget.role == 'installer' && item['title'] == 'Leads') return false;
          if (widget.role == 'dse' && item['title'] == 'Tickets') return false;
          return true;
        })
        .map((item) => {
              ...item,
              // Override route for CustomersTab to pass role
              if (item['title'] == 'Customers') 'route': CustomersTab(role: widget.role),
            })
        .toList();
  }

  // Filtered navigation items for dashboard cards, based on role and search query
  List<Map<String, dynamic>> get _filteredNavItems {
    List<Map<String, dynamic>> items = _baseNavItems
        .where((item) {
          if (widget.role == 'installer' && item['title'] == 'Leads') return false;
          if (widget.role == 'dse' && item['title'] == 'Tickets') return false;
          return true;
        })
        .map((item) => {
              ...item,
              // Override route for CustomersTab to pass role
              if (item['title'] == 'Customers') 'route': CustomersTab(role: widget.role),
            })
        .toList();

    if (_searchQuery.isEmpty) return items;
    return items
        .where((item) => item['title'].toString().toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    print('User role: ${widget.role}');
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFDF0613);
    const backgroundColor = Color(0xFFF5F7FA);
    const cardColor = Colors.white;

    // Responsive scaling
    final double scaleFactor = MediaQuery.of(context).textScaleFactor;
    final double devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    final double screenWidth = MediaQuery.of(context).size.width;

    // Fixed crossAxisCount to 2 for two cards per row
    const int crossAxisCount = 2;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Dashboard',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18 * scaleFactor,
            fontFamily: 'Nunito',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
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
                            'Welcome, ${widget.username}',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Nunito',
                              fontSize: 18 * scaleFactor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8 / devicePixelRatio),
                          Text(
                            'Manage your tasks efficiently',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontFamily: 'Nunito',
                              fontSize: 14 * scaleFactor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ..._drawerNavItems.map((item) => _buildDrawerItem(
                          icon: item['icon'],
                          title: item['title'],
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => item['route']),
                            );
                          },
                          primaryColor: primaryColor,
                        )),
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
                            SnackBar(
                              content: Text('Error: $e', style: TextStyle(fontSize: 14 * scaleFactor)),
                            ),
                          );
                        }
                      },
                      primaryColor: primaryColor,
                    ),
                  ],
                ),
              ),
              Container(
                height: 50 / devicePixelRatio,
                color: primaryColor,
                child: Center(
                  child: Text(
                    'OGDMS v1.0',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Nunito',
                      fontSize: 12 * scaleFactor,
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Padding(
              padding: EdgeInsets.all(16.0 / devicePixelRatio),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, ${widget.username}',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 20 * scaleFactor,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 16 / devicePixelRatio),
                  Container(
                    padding: EdgeInsets.all(16.0 / devicePixelRatio),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(12 / devicePixelRatio),
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search tasks',
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontFamily: 'Nunito',
                          fontSize: 14 * scaleFactor,
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12 / devicePixelRatio),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12 / devicePixelRatio),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12 / devicePixelRatio),
                          borderSide: BorderSide(
                            color: Colors.white.withOpacity(0.8),
                            width: 1 / devicePixelRatio,
                          ),
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.white.withOpacity(0.8),
                          size: 24,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 12 / devicePixelRatio,
                          horizontal: 16 / devicePixelRatio,
                        ),
                      ),
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Nunito',
                        fontSize: 14 * scaleFactor,
                      ),
                      cursorColor: Colors.white,
                      onChanged: (value) {
                        if (_debounce?.isActive ?? false) _debounce!.cancel();
                        _debounce = Timer(const Duration(milliseconds: 300), () {
                          setState(() {
                            _searchQuery = value;
                          });
                        });
                      },
                    ),
                  ),
                  SizedBox(height: 16 / devicePixelRatio),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 12 / devicePixelRatio,
                      mainAxisSpacing: 12 / devicePixelRatio,
                      childAspectRatio: screenWidth > 600 ? 1.2 : 1.0,
                      children: _filteredNavItems.map((item) {
                        return _NavCard(
                          title: item['title'],
                          icon: item['icon'],
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => item['route']),
                          ),
                          primaryColor: primaryColor,
                          cardColor: cardColor,
                          scaleFactor: scaleFactor,
                          devicePixelRatio: devicePixelRatio,
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            );
          },
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
    final double scaleFactor = MediaQuery.of(context).textScaleFactor;
    final double devicePixelRatio = MediaQuery.of(context).devicePixelRatio;

    return ListTile(
      leading: Icon(
        icon,
        color: primaryColor,
        size: 24,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 14 * scaleFactor,
          color: Colors.black87,
        ),
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(
        horizontal: 16 / devicePixelRatio,
        vertical: 2 / devicePixelRatio,
      ),
      tileColor: Colors.transparent,
      hoverColor: primaryColor.withOpacity(0.1),
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
  final double scaleFactor;
  final double devicePixelRatio;

  const _NavCard({
    required this.title,
    required this.icon,
    required this.onTap,
    required this.primaryColor,
    required this.cardColor,
    required this.scaleFactor,
    required this.devicePixelRatio,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12 / devicePixelRatio),
      ),
      color: cardColor,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12 / devicePixelRatio),
        splashColor: primaryColor.withOpacity(0.2),
        highlightColor: primaryColor.withOpacity(0.1),
        child: Padding(
          padding: EdgeInsets.all(16.0 / devicePixelRatio),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: primaryColor,
                size: 40,
              ),
              SizedBox(height: 8 / devicePixelRatio),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 12 * scaleFactor,
                  fontWeight: FontWeight.w600,
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