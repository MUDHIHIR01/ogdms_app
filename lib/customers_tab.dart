import 'package:flutter/material.dart';
import 'package:untitled1/api_service.dart';
import 'package:untitled1/home_screen.dart';
import 'package:untitled1/ticket_form_screen.dart';

class CustomersTab extends StatefulWidget {
  const CustomersTab({super.key});

  @override
  _CustomersTabState createState() => _CustomersTabState();
}

class _CustomersTabState extends State<CustomersTab> {
  late Future<List<Map<String, dynamic>>> _customersFuture;
  List<Map<String, dynamic>> _sites = [];

  @override
  void initState() {
    super.initState();
    _customersFuture = ApiService.getCustomers();
    _loadSites();
  }

  void _loadSites() async {
    try {
      _sites = await ApiService.getSites();
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading sites: $e', style: const TextStyle(fontSize: 14))),
      );
    }
  }

  void _showCustomerActionSheet(BuildContext context, Map<String, dynamic>? customer) {
    final _nameController = TextEditingController(text: customer?['name'] ?? '');
    final _emailController = TextEditingController(text: customer?['email'] ?? '');
    final _phoneController = TextEditingController(text: customer?['phone'] ?? '');
    final _idTypeController = TextEditingController(text: customer?['id_type'] ?? '');
    final _idNumberController = TextEditingController(text: customer?['id_number'] ?? '');
    final _tinNumberController = TextEditingController(text: customer?['tin_number'] ?? '');
    final _notesController = TextEditingController(text: customer?['notes'] ?? '');
    String? _selectedSiteId = customer?['site_id'];
    final _formKey = GlobalKey<FormState>();
    bool _createTicket = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      builder: (context) => StatefulBuilder( // Added StatefulBuilder to update checkbox state
        builder: (BuildContext context, StateSetter modalSetState) {
          return DraggableScrollableSheet(
            initialChildSize: 0.9,
            maxChildSize: 0.9,
            minChildSize: 0.5,
            expand: false,
            builder: (context, scrollController) => SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        customer == null ? 'Add Customer' : 'Edit Customer',
                        style: const TextStyle(fontFamily: 'Nunito', fontSize: 16),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _selectedSiteId,
                        decoration: const InputDecoration(
                          labelText: 'Site',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_on, color: Color(0xFFDF0613)),
                        ),
                        items: _sites.map((site) {
                          return DropdownMenuItem<String>(
                            value: site['id'],
                            child: Text(site['name'] ?? 'Unknown Site', style: const TextStyle(fontSize: 14)),
                          );
                        }).toList(),
                        onChanged: (value) => _selectedSiteId = value,
                        validator: (value) => value == null ? 'Select a site' : null,
                      ),
                      const SizedBox(height: 12),
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
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _idTypeController,
                        decoration: const InputDecoration(
                          labelText: 'ID Type',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.badge, color: Color(0xFFDF0613)),
                        ),
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _idNumberController,
                        decoration: const InputDecoration(
                          labelText: 'ID Number',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.badge, color: Color(0xFFDF0613)),
                        ),
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _tinNumberController,
                        decoration: const InputDecoration(
                          labelText: 'TIN Number',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.numbers, color: Color(0xFFDF0613)),
                        ),
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          labelText: 'Notes',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.note, color: Color(0xFFDF0613)),
                        ),
                        maxLines: 3,
                        style: const TextStyle(fontSize: 14),
                      ),
                      if (customer == null) ...[
                        const SizedBox(height: 12),
                        CheckboxListTile(
                          title: const Text('Create installation ticket', style: TextStyle(fontSize: 14)),
                          value: _createTicket,
                          onChanged: (value) => modalSetState(() => _createTicket = value!), // Use modalSetState
                        ),
                      ],
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            final customerData = {
                              'site_id': _selectedSiteId,
                              'name': _nameController.text,
                              'email': _emailController.text,
                              'phone': _phoneController.text,
                              'id_type': _idTypeController.text,
                              'id_number': _idNumberController.text,
                              'tin_number': _tinNumberController.text,
                              'notes': _notesController.text,
                            };
                            try {
                              String? customerId;
                              if (customer == null) {
                                final response = await ApiService.createCustomer(customerData);
                                customerId = response['id'];
                                if (_createTicket && customerId != null) {
                                  await ApiService.createTicket({
                                    'title': 'Installation for ${customerData['name']}',
                                    'description': 'Initial installation for new customer',
                                    'customer_id': customerId,
                                    'site_id': _selectedSiteId,
                                    'status': 'open',
                                    'type': 'installation',
                                  });
                                }
                              } else {
                                await ApiService.updateCustomer(customer['id'], customerData);
                              }
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Customer ${customer == null ? 'added' : 'updated'}', style: const TextStyle(fontSize: 14))),
                              );
                              setState(() {
                                _customersFuture = ApiService.getCustomers();
                              });
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
                        child: Text(customer == null ? 'Add' : 'Update', style: const TextStyle(fontSize: 14)),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel', style: TextStyle(fontSize: 14, color: Color(0xFFDF0613))),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Customers', style: TextStyle(color: Colors.white, fontSize: 16)),
        backgroundColor: const Color(0xFFDF0613),
        // Add this line to make the back arrow (and other AppBar icons) white
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _customersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading customers', style: TextStyle(fontFamily: 'Nunito', fontSize: 14)));
                }
                final customers = snapshot.data ?? [];
                if (customers.isEmpty) {
                  return const Center(
                    child: Text('No customers', style: TextStyle(fontFamily: 'Nunito', fontSize: 14)),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: customers.length,
                  itemBuilder: (context, index) {
                    final customer = customers[index];
                    return Card(
                      elevation: 1,
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFFDF0613),
                          child: Text(
                            customer['name']?.isNotEmpty == true ? customer['name'][0] : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'Nunito',
                              fontSize: 14,
                            ),
                          ),
                        ),
                        title: Text(
                          customer['name'] ?? 'Unknown',
                          style: const TextStyle(fontFamily: 'Nunito', fontSize: 14),
                        ),
                        subtitle: Text(
                          '${customer['email'] ?? ''} | ${customer['phone'] ?? ''}',
                          style: const TextStyle(fontFamily: 'Nunito', fontSize: 12),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Color(0xFFDF0613), size: 20),
                              onPressed: () => _showCustomerActionSheet(context, customer),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                              onPressed: () async {
                                try {
                                  await ApiService.deleteCustomer(customer['id']);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Customer deleted', style: TextStyle(fontSize: 14))),
                                  );
                                  setState(() {
                                    _customersFuture = ApiService.getCustomers();
                                  });
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error: $e', style: const TextStyle(fontSize: 14))),
                                  );
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.confirmation_number, color: Color(0xFFDF0613), size: 20),
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TicketFormScreen(customerId: customer['id']),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFDF0613),
        child: const Icon(Icons.add, size: 20, color: Colors.white),
        onPressed: () => _showCustomerActionSheet(context, null),
      ),
    );
  }
}