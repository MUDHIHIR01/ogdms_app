import 'package:flutter/material.dart';
import 'package:untitled1/api_service.dart';
import 'package:untitled1/auth_screen.dart';
import 'package:untitled1/home_screen.dart';

class ResetPasswordScreen extends StatelessWidget {
  final String email;
  const ResetPasswordScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final _passwordController = TextEditingController();
    final _confirmPasswordController = TextEditingController();
    final _tokenController = TextEditingController();
    bool _obscurePassword = true;
    bool _obscureConfirmPassword = true;

    return StatefulBuilder(
      builder: (context, setState) {
        return Scaffold(
          body: Stack(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.5,
                decoration: BoxDecoration(
                  color: const Color(0xFFDF0613),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
              Center(
                child: Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Reset Password',
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 16,
                              color: Color(0xFFDF0613),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _tokenController,
                            decoration: const InputDecoration(
                              labelText: 'Reset Token',
                              prefixIcon: Icon(Icons.vpn_key, color: Color(0xFFDF0613)),
                              border: OutlineInputBorder(),
                            ),
                            style: const TextStyle(fontSize: 14),
                            validator: (value) => value!.isEmpty ? 'Enter reset token' : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: 'New Password',
                              prefixIcon: const Icon(Icons.lock, color: Color(0xFFDF0613)),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                  color: const Color(0xFFDF0613),
                                ),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                              border: const OutlineInputBorder(),
                            ),
                            obscureText: _obscurePassword,
                            style: const TextStyle(fontSize: 14),
                            validator: (value) => value!.isEmpty ? 'Enter new password' : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _confirmPasswordController,
                            decoration: InputDecoration(
                              labelText: 'Confirm Password',
                              prefixIcon: const Icon(Icons.lock, color: Color(0xFFDF0613)),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                                  color: const Color(0xFFDF0613),
                                ),
                                onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                              ),
                              border: const OutlineInputBorder(),
                            ),
                            obscureText: _obscureConfirmPassword,
                            style: const TextStyle(fontSize: 14),
                            validator: (value) {
                              if (value!.isEmpty) return 'Confirm password';
                              if (value != _passwordController.text) return 'Passwords do not match';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                try {
                                  await ApiService.resetPassword(
                                    email,
                                    _passwordController.text,
                                    _tokenController.text,
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Password reset successful', style: TextStyle(fontSize: 14))),
                                  );
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (context) => const AuthScreen()),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error: $e', style: const TextStyle(fontSize: 14))),
                                  );
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 48),
                            ),
                            child: const Text('Reset Password', style: TextStyle(fontSize: 14)),
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const AuthScreen()),
                            ),
                            child: const Text(
                              'Back to Login',
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                color: Color(0xFFDF0613),
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
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
      },
    );
  }
}