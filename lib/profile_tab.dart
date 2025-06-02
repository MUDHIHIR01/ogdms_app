
import 'package:flutter/material.dart';
import 'package:untitled1/home_screen.dart';

class ProfileTab extends StatelessWidget {
const ProfileTab({super.key});

@override
Widget build(BuildContext context) {
final _formKey = GlobalKey<FormState>();
final _nameController = TextEditingController(text: 'John Doe');
final _emailController = TextEditingController(text: 'john@example.com');
final _phoneController = TextEditingController(text: '1234567890');

return Scaffold(
backgroundColor: Colors.white,
appBar: AppBar(
title: const Text('Profile', style: TextStyle(color: Colors.white, fontSize: 16)),
backgroundColor: const Color(0xFFDF0613),
),
body: Column(
children: [
Expanded(
child: SingleChildScrollView(
padding: const EdgeInsets.all(12),
child: Card(
elevation: 2,
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
child: Padding(
padding: const EdgeInsets.all(12),
child: Form(
key: _formKey,
child: Column(
children: [
const CircleAvatar(
radius: 30,
backgroundColor: Color(0xFFDF0613),
child: Icon(Icons.person, size: 30, color: Colors.white),
),
const SizedBox(height: 12),
TextFormField(
controller: _nameController,
decoration: const InputDecoration(
labelText: 'Name',
border: OutlineInputBorder(),
),
validator: (value) => value!.isEmpty ? 'Enter name' : null,
),
const SizedBox(height: 8),
TextFormField(
controller: _emailController,
decoration: const InputDecoration(
labelText: 'Email',
border: OutlineInputBorder(),
),
validator: (value) => value!.isEmpty ? 'Enter email' : null,
),
const SizedBox(height: 8),
TextFormField(
controller: _phoneController,
decoration: const InputDecoration(
labelText: 'Phone',
border: OutlineInputBorder(),
),
validator: (value) => value!.isEmpty ? 'Enter phone' : null,
),
const SizedBox(height: 12),
ElevatedButton(
onPressed: () {
if (_formKey.currentState!.validate()) {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(content: Text('Profile updated')),
);
}
},
child: const Text('Update Profile'),
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
builder: (context) => const HomeScreen(username: 'Guest'),
),
),
style: ElevatedButton.styleFrom(
backgroundColor: Colors.grey[300],
foregroundColor: Colors.black,
minimumSize: const Size(double.infinity, 36),
),
child: const Text('Back to Home'),
),
),
],
),
);
}
}