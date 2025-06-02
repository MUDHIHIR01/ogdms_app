import 'package:flutter/material.dart';
import 'package:untitled1/auth_screen.dart';
import 'package:untitled1/customers_tab.dart';
import 'package:untitled1/leads_tab.dart';
import 'package:untitled1/notifications_tab.dart';
import 'package:untitled1/profile_tab.dart';
import 'package:untitled1/tickets_tab.dart';

class HomeScreen extends StatelessWidget {
  final String username;
  const HomeScreen({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Changelog', style: TextStyle(color: Colors.white, fontSize: 16)),
        backgroundColor: const Color(0xFFDF0613),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xFFDF0613),
              ),
              child: Text(
                'Welcome, $username',
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Nunito',
                  fontSize: 20,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home, color: Color(0xFFDF0613)),
              title: const Text('Home', style: TextStyle(fontFamily: 'Nunito')),
              onTap: () {
                Navigator.pop(context); // Close drawer
                // Already on HomeScreen, no navigation needed
              },
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Color(0xFFDF0613)),
              title: const Text('Profile', style: TextStyle(fontFamily: 'Nunito')),
              onTap: () {
                Navigator.pop(context); // Close drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileTab()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.confirmation_number, color: Color(0xFFDF0613)),
              title: const Text('Tickets', style: TextStyle(fontFamily: 'Nunito')),
              onTap: () {
                Navigator.pop(context); // Close drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TicketsTab()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.people, color: Color(0xFFDF0613)),
              title: const Text('Customers', style: TextStyle(fontFamily: 'Nunito')),
              onTap: () {
                Navigator.pop(context); // Close drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CustomersTab()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.leaderboard, color: Color(0xFFDF0613)),
              title: const Text('Leads', style: TextStyle(fontFamily: 'Nunito')),
              onTap: () {
                Navigator.pop(context); // Close drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LeadsTab()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications, color: Color(0xFFDF0613)),
              title: const Text('Notifications', style: TextStyle(fontFamily: 'Nunito')),
              onTap: () {
                Navigator.pop(context); // Close drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NotificationsTab()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.login, color: Color(0xFFDF0613)),
              title: const Text('Login', style: TextStyle(fontFamily: 'Nunito')),
              onTap: () {
                Navigator.pop(context); // Close drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AuthScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.lock_reset, color: Color(0xFFDF0613)),
              title: const Text('Reset Password', style: TextStyle(fontFamily: 'Nunito')),
              onTap: () {
                Navigator.pop(context); // Close drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AuthScreen(isResetPassword: true),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, $username',
              style: const TextStyle(fontFamily: 'Nunito', fontSize: 16),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                children: [
                  _NavCard(
                    title: 'Profile',
                    icon: Icons.person,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ProfileTab()),
                    ),
                  ),
                  _NavCard(
                    title: 'Home',
                    icon: Icons.home,
                    onTap: () {}, // Stays on current page
                  ),
                  _NavCard(
                    title: 'Tickets',
                    icon: Icons.confirmation_number,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const TicketsTab()),
                    ),
                  ),
                  _NavCard(
                    title: 'Customers',
                    icon: Icons.people,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CustomersTab()),
                    ),
                  ),
                  _NavCard(
                    title: 'Leads',
                    icon: Icons.leaderboard,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LeadsTab()),
                    ),
                  ),
                  _NavCard(
                    title: 'Notifications',
                    icon: Icons.notifications,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const NotificationsTab()),
                    ),
                  ),
                  _NavCard(
                    title: 'Login',
                    icon: Icons.login,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AuthScreen()),
                    ),
                  ),
                  _NavCard(
                    title: 'Reset Password',
                    icon: Icons.lock_reset,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AuthScreen(isResetPassword: true),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _NavCard({required this.title, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: const Color(0xFFDF0613), size: 24),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(fontFamily: 'Nunito', fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}