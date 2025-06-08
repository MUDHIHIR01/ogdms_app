import 'package:flutter/material.dart';
import 'package:untitled1/api_service.dart';
import 'package:untitled1/home_screen.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  _ProfileTabState createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  late Future<Map<String, dynamic>> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = ApiService.getAuthenticatedUser();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Nunito')),
        backgroundColor: const Color(0xFFDF0613),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading profile', style: TextStyle(fontFamily: 'Nunito', fontSize: 14)));
          }
          final user = snapshot.data ?? {};
          _nameController.text = '${user['first_name'] ?? ''} ${user['last_name'] ?? ''}';
          _emailController.text = user['email'] ?? '';
          _phoneController.text = user['phone'] ?? '';

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(12),
                  child: Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundImage: user['profile_photo_url'] != null
                                  ? NetworkImage(user['profile_photo_url'])
                                  : null,
                              backgroundColor: const Color(0xFFDF0613),
                              child: user['profile_photo_url'] == null
                                  ? const Icon(Icons.person, size: 24, color: Colors.white)
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: 'Name',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.person, color: Color(0xFFDF0613)),
                              ),
                              style: const TextStyle(fontSize: 14),
                              validator: (value) => value!.isEmpty ? 'Enter name' : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.email, color: Color(0xFFDF0613)),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              style: const TextStyle(fontSize: 14),
                              validator: (value) => value!.isEmpty ? 'Enter email' : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _phoneController,
                              decoration: const InputDecoration(
                                labelText: 'Phone',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.phone, color: Color(0xFFDF0613)),
                              ),
                              keyboardType: TextInputType.phone,
                              style: const TextStyle(fontSize: 14),
                              validator: (value) => value!.isEmpty ? 'Enter phone' : null,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Profile updated', style: TextStyle(fontSize: 14))),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 48),
                              ),
                              child: const Text('Update Profile', style: TextStyle(fontSize: 14)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: ElevatedButton(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HomeScreen(username: 'Guest', role: '',),
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
          );
        },
      ),
    );
  }
}