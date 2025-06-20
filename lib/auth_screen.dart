import 'package:flutter/material.dart';
import 'api_service.dart';
import 'home_screen.dart';
import 'reset_password_screen.dart';

// 1. Converted to a StatefulWidget
class AuthScreen extends StatefulWidget {
  final bool isResetPassword;
  const AuthScreen({super.key, this.isResetPassword = false});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

// 2. Created a State class
class _AuthScreenState extends State<AuthScreen> {
  // 3. Moved all state-related variables here
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late bool _isLogin;
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize state based on widget properties
    _isLogin = !widget.isResetPassword;
  }

  @override
  void dispose() {
    // 4. Dispose controllers to prevent memory leaks
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void showErrorSnackBar(String message) {
    // Check if the context is still valid before showing a SnackBar
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  // 5. Moved the build logic into the State class
  @override
  Widget build(BuildContext context) {
    final inputDecoration = InputDecoration(
      labelStyle: const TextStyle(color: Colors.grey),
      prefixIconColor: const Color(0xFFDF0613),
      suffixIconColor: const Color(0xFFDF0613),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFDF0613)),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );

    // 6. Removed the StatefulBuilder, as this is now a StatefulWidget
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.3,
              decoration: const BoxDecoration(
                color: Color(0xFFDF0613),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: const Center(
                child: Text(
                  'OGDMS',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Column(
              children: [
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Card(
                        elevation: 4,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _isLogin ? 'Login' : 'Forgot Password',
                                  style: const TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 20,
                                    color: Color(0xFFDF0613),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                TextFormField(
                                  controller: _emailController,
                                  decoration: inputDecoration.copyWith(
                                    labelText: 'Email',
                                    prefixIcon: const Icon(Icons.email, size: 20),
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter email';
                                    }
                                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                      return 'Please enter a valid email';
                                    }
                                    return null;
                                  },
                                ),
                                if (_isLogin) ...[
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _passwordController,
                                    decoration: inputDecoration.copyWith(
                                      labelText: 'Password',
                                      prefixIcon: const Icon(Icons.lock, size: 20),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                          size: 20,
                                        ),
                                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                      ),
                                    ),
                                    obscureText: _obscurePassword,
                                    validator: (value) => value!.isEmpty ? 'Please enter password' : null,
                                  ),
                                ],
                                const SizedBox(height: 24),
                                _isLoading
                                    ? const CircularProgressIndicator(color: Color(0xFFDF0613))
                                    : ElevatedButton(
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate()) {
                                      setState(() => _isLoading = true);
                                      try {
                                        if (_isLogin) {
                                          final result = await ApiService.login(
                                            _emailController.text,
                                            _passwordController.text,
                                          );
                                          final user = result['user'];
                                          final username = '${user['first_name']} ${user['last_name']}';
                                          final role = result['role']?.toString().toLowerCase() ?? 'default';

                                          // Check mounted before navigating
                                          if (!mounted) return;
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => HomeScreen(
                                                username: username,
                                                role: role,
                                              ),
                                            ),
                                          );
                                        } else {
                                          final token = await ApiService.forgotPassword(
                                              _emailController.text);
                                          // Check mounted before showing snackbar/navigating
                                          if (!mounted) return;
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Reset link sent to your email'),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ResetPasswordScreen(
                                                email: _emailController.text,
                                                token: token,
                                              ),
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        String errorMessage;
                                        switch (e.toString()) {
                                          case 'The provided credentials are incorrect.':
                                            errorMessage = 'Invalid email or password';
                                            break;
                                          case 'No internet connection':
                                            errorMessage = 'No internet connection. Please check your network';
                                            break;
                                          case 'Request timed out':
                                            errorMessage = 'Request timed out. Please try again';
                                            break;
                                          default:
                                            errorMessage = 'An error occurred: $e';
                                        }
                                        showErrorSnackBar(errorMessage);
                                      } finally {
                                        // 7. This is now valid, as `mounted` is a property of the State class
                                        if (mounted) {
                                          setState(() => _isLoading = false);
                                        }
                                      }
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size(double.infinity, 48),
                                  ),
                                  child: Text(_isLogin ? 'Login' : 'Send Reset Link'),
                                ),
                                const SizedBox(height: 16),
                                TextButton(
                                  onPressed: () => setState(() => _isLogin = !_isLogin),
                                  child: Text(
                                    _isLogin ? 'Forgot Password?' : 'Back to Login',
                                    style: const TextStyle(
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
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Text(
                    'version 1.0',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 16,
                      color: Color(0xFFDF0613),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}