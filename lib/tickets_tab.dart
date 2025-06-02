
import 'package:flutter/material.dart';
import 'package:untitled1/home_screen.dart';

class TicketsTab extends StatelessWidget {
const TicketsTab({super.key});

void _showTicketDialog(BuildContext context, Map<String, String>? ticket) {
final _titleController = TextEditingController(text: ticket?['title'] ?? '');
final _descriptionController = TextEditingController(text: ticket?['description'] ?? '');
final _formKey = GlobalKey<FormState>();

showDialog(
context: context,
builder: (context) => AlertDialog(
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
title: Text(
ticket == null ? 'Add Ticket' : 'Edit Ticket',
style: const TextStyle(fontFamily: 'Nunito', fontSize: 14),
),
content: Form(
key: _formKey,
child: Column(
mainAxisSize: MainAxisSize.min,
children: [
TextFormField(
controller: _titleController,
decoration: const InputDecoration(
labelText: 'Title',
border: OutlineInputBorder(),
),
validator: (value) => value!.isEmpty ? 'Enter title' : null,
),
const SizedBox(height: 8),
TextFormField(
controller: _descriptionController,
decoration: const InputDecoration(
labelText: 'Description',
border: OutlineInputBorder(),
),
maxLines: 2,
validator: (value) => value!.isEmpty ? 'Enter description' : null,
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
SnackBar(content: Text('Ticket ${ticket == null ? 'added' : 'updated'}')),
);
}
},
child: Text(ticket == null ? 'Add' : 'Update'),
),
],
),
);
}

@override
Widget build(BuildContext context) {
const demoTickets = [
{'title': 'Issue #1', 'description': 'App crash'},
{'title': 'Issue #2', 'description': 'Slow loading'},
];

return Scaffold(
backgroundColor: Colors.white,
appBar: AppBar(
title: const Text('Tickets', style: TextStyle(color: Colors.white, fontSize: 16)),
backgroundColor: const Color(0xFFDF0613),
),
body: Column(
children: [
Expanded(
child: demoTickets.isEmpty
? const Center(
child: Text('No tickets', style: TextStyle(fontFamily: 'Nunito', fontSize: 14)))
    : ListView.builder(
padding: const EdgeInsets.all(12),
itemCount: demoTickets.length,
itemBuilder: (context, index) {
final ticket = demoTickets[index];
return Card(
elevation: 2,
margin: const EdgeInsets.only(bottom: 8),
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
child: ListTile(
leading: CircleAvatar(
backgroundColor: const Color(0xFFDF0613),
child: Text(
ticket['title']![0],
style: const TextStyle(
color: Colors.white, fontFamily: 'Nunito', fontSize: 12),
),
),
title: Text(ticket['title']!,
style: const TextStyle(fontFamily: 'Nunito', fontSize: 12)),
subtitle: Text(ticket['description']!,
style: const TextStyle(fontFamily: 'Nunito', fontSize: 12)),
trailing: Row(
mainAxisSize: MainAxisSize.min,
children: [
IconButton(
icon: const Icon(Icons.edit, color: Color(0xFFDF0613), size: 16),
onPressed: () => _showTicketDialog(context, ticket),
),
IconButton(
icon: const Icon(Icons.delete, color: Colors.red, size: 16),
onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(content: Text('Ticket deleted')),
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
onPressed: () => _showTicketDialog(context, null),
),
);
}
}
