
import 'package:flutter/material.dart';
import 'package:untitled1/home_screen.dart';

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
backgroundColor: Colors.white,
appBar: AppBar(
title: Text(
_isLogin ? 'Login' : 'Reset Password',
style: const TextStyle(color: Colors.white, fontSize: 16),
),
backgroundColor: const Color(0xFFDF0613),
),
body: Padding(
padding: const EdgeInsets.all(12),
child: Column(
children: [
Expanded(
child: Center(
child: Card(
elevation: 2,
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
child: Padding(
padding: const EdgeInsets.all(12),
child: Form(
key: _formKey,
child: Column(
mainAxisSize: MainAxisSize.min,
children: [
TextFormField(
controller: _emailController,
decoration: const InputDecoration(
labelText: 'Email',
prefixIcon: Icon(Icons.email, color: Color(0xFFDF0613), size: 16),
),
keyboardType: TextInputType.emailAddress,
validator: (value) => value!.isEmpty ? 'Enter email' : null,
),
if (_isLogin) ...[
const SizedBox(height: 8),
TextFormField(
controller: _passwordController,
decoration: InputDecoration(
labelText: 'Password',
prefixIcon: Icon(Icons.lock, color: Color(0xFFDF0613), size: 16),
suffixIcon: IconButton(
icon: Icon(
_obscurePassword ? Icons.visibility : Icons.visibility_off,
color: const Color(0xFFDF0613),
size: 16,
),
onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
),
),
obscureText: _obscurePassword,
validator: (value) => value!.isEmpty ? 'Enter password' : null,
),
],
const SizedBox(height: 12),
ElevatedButton(
onPressed: () {
if (_formKey.currentState!.validate()) {
Navigator.pushReplacement(
context,
MaterialPageRoute(
builder: (context) => const HomeScreen(username: 'John Doe'),
),
);
if (!_isLogin) {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(content: Text('Reset link sent')),
);
}
}
},
child: Text(_isLogin ? 'Login' : 'Send Reset Link'),
),
const SizedBox(height: 8),
TextButton(
onPressed: () => setState(() => _isLogin = !_isLogin),
child: Text(
_isLogin ? 'Forgot Password?' : 'Back to Login',
style: const TextStyle(
fontFamily: 'Nunito',
color: Color(0xFFDF0613),
fontSize: 12,
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
ElevatedButton(
onPressed: () => Navigator.pushReplacement(
context,
MaterialPageRoute(
builder: (context) => const HomeScreen(username: 'Guest'),
),
),
style: ElevatedButton.styleFrom(
backgroundColor: Colors.grey[300],
foregroundColor: Colors.black,
),
child: const Text('Back to Home'),
),
],
),
),
);
},
);
}
}