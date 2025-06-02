
import 'package:flutter/material.dart';
import 'package:untitled1/home_screen.dart';

class CustomersTab extends StatelessWidget {
const CustomersTab({super.key});

void _showCustomerDialog(BuildContext context, Map<String, String>? customer) {
final _nameController = TextEditingController(text: customer?['name'] ?? '');
final _emailController = TextEditingController(text: customer?['email'] ?? '');
final _phoneController = TextEditingController(text: customer?['phone'] ?? '');
final _formKey = GlobalKey<FormState>();

showDialog(
context: context,
builder: (context) => AlertDialog(
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
title: Text(
customer == null ? 'Add Customer' : 'Edit Customer',
style: const TextStyle(fontFamily: 'Nunito', fontSize: 14),
),
content: Form(
key: _formKey,
child: Column(
mainAxisSize: MainAxisSize.min,
children: [
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
],
),
),
actions: [
ElevatedButton(
onPressed: () {
if (_formKey.currentState!.validate()) {
Navigator.pop(context);
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(content: Text('Customer ${customer == null ? 'added' : 'updated'}')),
);
}
},
child: Text(customer == null ? 'Add' : 'Update'),
),
],
),
);
}

@override
Widget build(BuildContext context) {
const demoCustomers = [
{'name': 'Alice', 'email': 'alice@example.com', 'phone': '1234567890'},
{'name': 'Bob', 'email': 'bob@example.com', 'phone': '0987654321'},
];

return Scaffold(
backgroundColor: Colors.white,
appBar: AppBar(
title: const Text('Customers', style: TextStyle(color: Colors.white, fontSize: 16)),
backgroundColor: const Color(0xFFDF0613),
),
body: Column(
children: [
Expanded(
child: demoCustomers.isEmpty
? const Center(
child: Text('No customers', style: TextStyle(fontFamily: 'Nunito', fontSize: 14)))
    : ListView.builder(
padding: const EdgeInsets.all(12),
itemCount: demoCustomers.length,
itemBuilder: (context, index) {
final customer = demoCustomers[index];
return Card(
elevation: 2,
margin: const EdgeInsets.only(bottom: 8),
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
child: ListTile(
leading: CircleAvatar(
backgroundColor: const Color(0xFFDF0613),
child: Text(
customer['name']![0],
style: const TextStyle(
color: Colors.white, fontFamily: 'Nunito', fontSize: 12),
),
),
title: Text(customer['name']!,
style: const TextStyle(fontFamily: 'Nunito', fontSize: 12)),
subtitle: Text('${customer['email']} | ${customer['phone']}',
style: const TextStyle(fontFamily: 'Nunito', fontSize: 12)),
trailing: Row(
mainAxisSize: MainAxisSize.min,
children: [
IconButton(
icon: const Icon(Icons.edit, color: Color(0xFFDF0613), size: 16),
onPressed: () => _showCustomerDialog(context, customer),
),
IconButton(
icon: const Icon(Icons.delete, color: Colors.red, size: 16),
onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(content: Text('Customer deleted')),
),
),
],
),
),
);
},
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
floatingActionButton: FloatingActionButton(
backgroundColor: const Color(0xFFDF0613),
child: const Icon(Icons.add, size: 16, color: Colors.white),
onPressed: () => _showCustomerDialog(context, null),
),
);
}
}