import 'package:flutter/material.dart';
import 'package:untitled1/api_service.dart';
import 'package:untitled1/home_screen.dart';
import 'package:untitled1/reset_password_screen.dart';

class AuthScreen extends StatelessWidget {
  final bool isResetPassword;
  const AuthScreen({super.key, this.isResetPassword = false});

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final _emailController = TextEditingController();
    final _passwordController = TextEditingController();
    bool _isLogin = !isResetPassword;
    bool _obscurePassword = true;

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
                child: const Center(
                  child: Text(
                    'OGDMS',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 24,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Center(
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _isLogin ? 'Login' : 'Forgot Password',
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 16,
                              color: Color(0xFFDF0613),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email, color: Color(0xFFDF0613)),
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(fontSize: 14, color: Colors.white), // Changed to white
                            validator: (value) => value!.isEmpty ? 'Enter email' : null,
                          ),
                          if (_isLogin) ...[
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _passwordController,
                              decoration: InputDecoration(
                                labelText: 'Password',
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
                              style: const TextStyle(fontSize: 14, color: Colors.white), // Changed to white
                              validator: (value) => value!.isEmpty ? 'Enter password' : null,
                            ),
                          ],
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                try {
                                  if (_isLogin) {
                                    final result = await ApiService.login(
                                      _emailController.text,
                                      _passwordController.text,
                                    );
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => HomeScreen(username: result['name'] ?? 'Guest'),
                                      ),
                                    );
                                  } else {
                                    await ApiService.forgotPassword(_emailController.text);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Reset link sent', style: TextStyle(fontSize: 14, color: Colors.white))), // Changed to white
                                    );
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ResetPasswordScreen(email: _emailController.text),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error: $e', style: const TextStyle(fontSize: 14, color: Colors.white))), // Changed to white
                                  );
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 48),
                            ),
                            child: Text(_isLogin ? 'Login' : 'Send Reset Link', style: const TextStyle(fontSize: 14, color: Colors.white)), // Changed to white
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () => setState(() => _isLogin = !_isLogin),
                            child: Text(
                              _isLogin ? 'Forgot Password?' : 'Back to Login',
                              style: const TextStyle(
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
                    foregroundColor: Colors.white, // Changed to white
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Back to Home', style: TextStyle(fontSize: 14, color: Colors.white)), // Changed to white
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}