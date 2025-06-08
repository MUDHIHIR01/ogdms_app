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
  List<Map<String, dynamic>> _filteredCustomers = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoadingSites = true;

  @override
  void initState() {
    super.initState();
    _customersFuture = _fetchCustomers();
    _loadSites();
    _searchController.addListener(_filterCustomers);
  }

  Future<List<Map<String, dynamic>>> _fetchCustomers() async {
    try {
      final customers = await ApiService.getCustomers();
      _filteredCustomers = customers; // Initialize filtered list
      return customers;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load customers: $e', style: const TextStyle(fontFamily: 'Nunito', fontSize: 14)),
          ),
        );
      }
      return [];
    }
  }

  void _loadSites() async {
    try {
      _sites = await ApiService.getSites();
      setState(() {
        _isLoadingSites = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingSites = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load sites: $e', style: const TextStyle(fontFamily: 'Nunito', fontSize: 14)),
          ),
        );
      }
    }
  }

  void _filterCustomers() {
    _customersFuture.then((customers) {
      final query = _searchController.text.toLowerCase();
      setState(() {
        _filteredCustomers = customers.where((customer) {
          final name = customer['name']?.toLowerCase() ?? '';
          final email = customer['email']?.toLowerCase() ?? '';
          final phone = customer['phone']?.toLowerCase() ?? '';
          return name.contains(query) || email.contains(query) || phone.contains(query);
        }).toList();
      });
    });
  }

  void _refreshCustomers() {
    setState(() {
      _customersFuture = _fetchCustomers();
    });
  }

  void _showCustomerActionSheet(BuildContext context, Map<String, dynamic>? customer) {
    final _nameController = TextEditingController(text: customer?['name'] ?? '');
    final _emailController = TextEditingController(text: customer?['email'] ?? '');
    final _phoneController = TextEditingController(text: customer?['phone'] ?? '');
    final _idTypeController = TextEditingController(text: customer?['id_type'] ?? '');
    final _idNumberController = TextEditingController(text: customer?['id_number'] ?? '');
    final _tinNumberController = TextEditingController(text: customer?['tin_number'] ?? '');
    final _addressController = TextEditingController(text: customer?['address'] ?? '');
    final _latitudeController = TextEditingController(text: customer?['latitude']?.toString() ?? '');
    final _longitudeController = TextEditingController(text: customer?['longitude']?.toString() ?? '');
    final _notesController = TextEditingController(text: customer?['notes'] ?? '');
    String? _selectedSiteId = customer?['site_id']?.toString();
    final _formKey = GlobalKey<FormState>();
    bool _createTicket = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (context) => StatefulBuilder(
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer == null ? 'Add Customer' : 'Edit Customer',
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedSiteId,
                        decoration: InputDecoration(
                          labelText: 'Site',
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFDF0613), width: 1),
                          ),
                          prefixIcon: const Icon(Icons.location_on, color: Color(0xFFDF0613)),
                        ),
                        hint: _isLoadingSites
                            ? const Text('Loading sites...', style: TextStyle(fontFamily: 'Nunito', fontSize: 14))
                            : _sites.isEmpty
                            ? const Text('No sites available', style: TextStyle(fontFamily: 'Nunito', fontSize: 14))
                            : const Text('Select a site', style: TextStyle(fontFamily: 'Nunito', fontSize: 14)),
                        items: _sites.map((site) {
                          return DropdownMenuItem<String>(
                            value: site['id'].toString(),
                            child: Text(
                              site['name'] ?? 'Unknown Site',
                              style: const TextStyle(fontFamily: 'Nunito', fontSize: 14),
                            ),
                          );
                        }).toList(),
                        onChanged: _isLoadingSites || _sites.isEmpty
                            ? null
                            : (value) => modalSetState(() => _selectedSiteId = value),
                        validator: (value) => value == null ? 'Please select a site' : null,
                      ),
                      const SizedBox(height: 12),
                      _buildTextFormField(
                        controller: _nameController,
                        label: 'Name',
                        icon: Icons.person,
                        validator: (value) => value!.isEmpty ? 'Enter name' : null,
                      ),
                      const SizedBox(height: 12),
                      _buildTextFormField(
                        controller: _emailController,
                        label: 'Email',
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) => value!.isEmpty ? 'Enter email' : null,
                      ),
                      const SizedBox(height: 12),
                      _buildTextFormField(
                        controller: _phoneController,
                        label: 'Phone',
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        validator: (value) => value!.isEmpty ? 'Enter phone' : null,
                      ),
                      const SizedBox(height: 12),
                      _buildTextFormField(
                        controller: _addressController,
                        label: 'Address',
                        icon: Icons.home,
                        validator: (value) => value!.isEmpty ? 'Enter address' : null,
                      ),
                      const SizedBox(height: 12),
                      _buildTextFormField(
                        controller: _latitudeController,
                        label: 'Latitude',
                        icon: Icons.map,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      _buildTextFormField(
                        controller: _longitudeController,
                        label: 'Longitude',
                        icon: Icons.map,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      _buildTextFormField(
                        controller: _idTypeController,
                        label: 'ID Type',
                        icon: Icons.badge,
                      ),
                      const SizedBox(height: 12),
                      _buildTextFormField(
                        controller: _idNumberController,
                        label: 'ID Number',
                        icon: Icons.badge,
                      ),
                      const SizedBox(height: 12),
                      _buildTextFormField(
                        controller: _tinNumberController,
                        label: 'TIN Number',
                        icon: Icons.numbers,
                      ),
                      const SizedBox(height: 12),
                      _buildTextFormField(
                        controller: _notesController,
                        label: 'Notes',
                        icon: Icons.note,
                        maxLines: 3,
                      ),
                      if (customer == null) ...[
                        const SizedBox(height: 12),
                        CheckboxListTile(
                          title: const Text(
                            'Create installation ticket',
                            style: TextStyle(fontFamily: 'Nunito', fontSize: 14),
                          ),
                          value: _createTicket,
                          onChanged: (value) => modalSetState(() => _createTicket = value!),
                          activeColor: const Color(0xFFDF0613),
                        ),
                      ],
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            final customerData = {
                              'site_id': _selectedSiteId,
                              'name': _nameController.text,
                              'email': _emailController.text,
                              'phone': _phoneController.text,
                              'address': _addressController.text,
                              'latitude': _latitudeController.text.isEmpty ? null : double.tryParse(_latitudeController.text),
                              'longitude': _longitudeController.text.isEmpty ? null : double.tryParse(_longitudeController.text),
                              'id_type': _idTypeController.text,
                              'id_number': _idNumberController.text,
                              'tin_number': _tinNumberController.text,
                              'notes': _notesController.text,
                            };
                            try {
                              String? customerId;
                              if (customer == null) {
                                final response = await ApiService.createCustomer(customerData);
                                customerId = response['id']?.toString();
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
                                await ApiService.updateCustomer(customer['id'].toString(), customerData);
                              }
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Customer ${customer == null ? 'added' : 'updated'} successfully',
                                    style: const TextStyle(fontFamily: 'Nunito', fontSize: 14),
                                  ),
                                ),
                              );
                              _refreshCustomers();
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: $e', style: const TextStyle(fontFamily: 'Nunito', fontSize: 14)),
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                          backgroundColor: const Color(0xFFDF0613),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          customer == null ? 'Add Customer' : 'Update Customer',
                          style: const TextStyle(fontFamily: 'Nunito', fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 14,
                            color: Color(0xFFDF0613),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    ).whenComplete(() {
      _nameController.dispose();
      _emailController.dispose();
      _phoneController.dispose();
      _idTypeController.dispose();
      _idNumberController.dispose();
      _tinNumberController.dispose();
      _addressController.dispose();
      _latitudeController.dispose();
      _longitudeController.dispose();
      _notesController.dispose();
    });
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFDF0613), width: 1),
        ),
        prefixIcon: Icon(icon, color: const Color(0xFFDF0613)),
      ),
      keyboardType: keyboardType,
      style: const TextStyle(fontFamily: 'Nunito', fontSize: 14),
      validator: validator,
      maxLines: maxLines,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFDF0613);
    const backgroundColor = Colors.white;
    const cardColor = Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Customers',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontFamily: 'Nunito',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name, email, or phone',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: primaryColor, width: 1),
                ),
                prefixIcon: const Icon(Icons.search, color: primaryColor),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear, color: primaryColor),
                  onPressed: () {
                    _searchController.clear();
                    _filterCustomers();
                  },
                )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
              style: const TextStyle(fontFamily: 'Nunito', fontSize: 14, color: Colors.black87),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _customersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: primaryColor));
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Error loading customers',
                          style: TextStyle(fontFamily: 'Nunito', fontSize: 14),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _refreshCustomers,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text(
                            'Retry',
                            style: TextStyle(fontFamily: 'Nunito', fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                final customers = snapshot.data ?? [];
                if (_filteredCustomers.isEmpty && _searchController.text.isNotEmpty) {
                  return const Center(
                    child: Text(
                      'No matching customers',
                      style: TextStyle(fontFamily: 'Nunito', fontSize: 14),
                    ),
                  );
                }
                if (_filteredCustomers.isEmpty && customers.isEmpty) {
                  return const Center(
                    child: Text(
                      'No customers available',
                      style: TextStyle(fontFamily: 'Nunito', fontSize: 14),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _filteredCustomers.length,
                  itemBuilder: (context, index) {
                    final customer = _filteredCustomers[index];
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      color: cardColor,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        leading: CircleAvatar(
                          backgroundColor: primaryColor,
                          radius: 20,
                          child: Text(
                            customer['name']?.isNotEmpty == true ? customer['name'][0].toUpperCase() : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'Nunito',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          customer['name'] ?? 'Unknown',
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        subtitle: Text(
                          '${customer['email'] ?? 'No email'} | ${customer['phone'] ?? 'No phone'}',
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: primaryColor, size: 24),
                              onPressed: () => _showCustomerActionSheet(context, customer),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red, size: 24),
                              onPressed: () => _deleteCustomer(context, customer['id']),
                            ),
                            IconButton(
                              icon: const Icon(Icons.confirmation_number, color: primaryColor, size: 24),
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TicketFormScreen(customerId: customer['id'].toString()),
                                ),
                              ).then((_) => _refreshCustomers()),
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
                MaterialPageRoute(builder: (context) => const HomeScreen(username: 'Guest')),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                backgroundColor: Colors.grey[300],
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'Back to Home',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: () => _showCustomerActionSheet(context, null),
        child: const Icon(Icons.add, size: 24, color: Colors.white),
      ),
    );
  }

  Future<void> _deleteCustomer(BuildContext context, String? customerId) async {
    if (customerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid customer ID', style: TextStyle(fontFamily: 'Nunito', fontSize: 14)),
        ),
      );
      return;
    }
    try {
      await ApiService.deleteCustomer(customerId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Customer deleted successfully', style: TextStyle(fontFamily: 'Nunito', fontSize: 14)),
        ),
      );
      _refreshCustomers();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete customer: $e', style: const TextStyle(fontFamily: 'Nunito', fontSize: 14)),
        ),
      );
    }
  }
}