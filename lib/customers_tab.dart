import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:untitled1/api_service.dart';
import 'package:untitled1/ticket_form_screen.dart';

class CustomersTab extends StatefulWidget {
  final String role; // Added role parameter
  const CustomersTab({super.key, required this.role});

  @override
  _CustomersTabState createState() => _CustomersTabState();
}

class _CustomersTabState extends State<CustomersTab> {
  late Future<void> _customersLoaderFuture;
  List<Map<String, dynamic>> _allCustomers = [];
  List<Map<String, dynamic>> _filteredCustomers = [];
  List<Map<String, dynamic>> _sites = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoadingSites = true;

  @override
  void initState() {
    super.initState();
    _customersLoaderFuture = _fetchAndSetCustomers();
    _loadSites();
    _searchController.addListener(_filterCustomers);
  }

  Future<void> _fetchAndSetCustomers() async {
    try {
      final customers = await ApiService.getCustomers();
      if (mounted) {
        setState(() {
          _allCustomers = customers;
          _filteredCustomers = customers;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load customers: $e', style: const TextStyle(fontFamily: 'Nunito', fontSize: 14))),
        );
      }
      rethrow;
    }
  }

  void _loadSites() async {
    try {
      final sites = await ApiService.getSites();
      if (mounted) {
        setState(() {
          _sites = sites;
          _isLoadingSites = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingSites = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load sites: $e', style: const TextStyle(fontFamily: 'Nunito', fontSize: 14))),
        );
      }
    }
  }

  void _filterCustomers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCustomers = _allCustomers.where((customer) {
        final name = customer['name']?.toLowerCase() ?? '';
        final email = customer['email']?.toLowerCase() ?? '';
        final phone = customer['phone']?.toLowerCase() ?? '';
        return name.contains(query) || email.contains(query) || phone.contains(query);
      }).toList();
    });
  }

  void _refreshCustomers() {
    setState(() {
      _customersLoaderFuture = _fetchAndSetCustomers();
    });
  }

  Future<Map<String, String>?> _getCurrentLocationAsString() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Location services are disabled. Please enable them.';
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permissions are denied.';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'Location permissions are permanently denied.';
      }

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      return {
        'latitude': position.latitude.toString(),
        'longitude': position.longitude.toString(),
      };
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to get location: $e', style: const TextStyle(fontFamily: 'Nunito', fontSize: 14))),
        );
      }
      return null;
    }
  }

  void _showCustomerActionSheet(BuildContext context, Map<String, dynamic>? customer) {
    if (widget.role == 'installer') return; // Prevent opening form for installers
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
      builder: (context) => CustomerFormSheet(
        customer: customer,
        sites: _sites,
        isLoadingSites: _isLoadingSites,
        onSave: _refreshCustomers,
        role: widget.role, // Pass role to CustomerFormSheet
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFDF0613);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers', style: TextStyle(color: Colors.white, fontSize: 18, fontFamily: 'Nunito', fontWeight: FontWeight.bold)),
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
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                prefixIcon: const Icon(Icons.search, color: primaryColor),
                suffixIcon: _searchController.text.isNotEmpty ? IconButton(icon: const Icon(Icons.clear, color: primaryColor), onPressed: () => _searchController.clear()) : null,
              ),
              style: const TextStyle(fontFamily: 'Nunito', fontSize: 14, color: Colors.black87),
            ),
          ),
          Expanded(
            child: FutureBuilder<void>(
              future: _customersLoaderFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: primaryColor));
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(fontFamily: 'Nunito')));
                }
                if (_filteredCustomers.isEmpty) {
                  return Center(child: Text(_allCustomers.isEmpty ? 'No customers yet.' : 'No matching customers found.', style: const TextStyle(fontFamily: 'Nunito')));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _filteredCustomers.length,
                  itemBuilder: (context, index) {
                    final customer = _filteredCustomers[index];
                    final customerId = customer['id']?.toString();
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      color: Colors.white,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        leading: CircleAvatar(
                          backgroundColor: primaryColor,
                          child: Text(
                            customer['name']?.isNotEmpty == true ? customer['name'][0].toUpperCase() : '?',
                            style: const TextStyle(color: Colors.white, fontFamily: 'Nunito', fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(customer['name'] ?? 'Unknown', style: const TextStyle(fontFamily: 'Nunito', fontSize: 16, fontWeight: FontWeight.w600)),
                        subtitle: Text('${customer['email'] ?? 'No email'} | ${customer['phone'] ?? 'No phone'}', style: const TextStyle(fontFamily: 'Nunito', fontSize: 14, color: Colors.black54)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.role == 'dse') // Show edit button only for DSE
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.green),
                                onPressed: () => _showCustomerActionSheet(context, customer),
                              ),
                            if (widget.role == 'dse' && customerId != null) // Show delete button only for DSE
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _showDeleteConfirmationDialog(context, customerId),
                              ),
                            if (customerId != null) // Ticket creation available for both roles
                              IconButton(
                                icon: const Icon(Icons.confirmation_number, color: Colors.blue),
                                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => TicketFormScreen(customerId: customerId))).then((_) => _refreshCustomers()),
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
        ],
      ),
      floatingActionButton: widget.role == 'dse' // Show FAB only for DSE
          ? FloatingActionButton(
              backgroundColor: primaryColor,
              onPressed: () => _showCustomerActionSheet(context, null),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Future<void> _showDeleteConfirmationDialog(BuildContext context, String customerId) async {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Customer', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to delete this customer?', style: TextStyle(fontFamily: 'Nunito')),
        actions: [
          TextButton(
            child: const Text('Cancel', style: TextStyle(fontFamily: 'Nunito', color: Colors.grey)),
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
          TextButton(
            child: const Text('Delete', style: TextStyle(fontFamily: 'Nunito', color: Colors.red, fontWeight: FontWeight.bold)),
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await _deleteCustomer(context, customerId);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCustomer(BuildContext context, String customerId) async {
    try {
      await ApiService.deleteCustomer(customerId);
      if (mounted) {
        setState(() {
          _allCustomers.removeWhere((customer) => customer['id'].toString() == customerId);
          _filteredCustomers.removeWhere((customer) => customer['id'].toString() == customerId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Customer deleted successfully', style: TextStyle(fontFamily: 'Nunito', fontSize: 14))),
        );
        _refreshCustomers();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete customer: $e', style: const TextStyle(fontFamily: 'Nunito', fontSize: 14))),
        );
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class CustomerFormSheet extends StatefulWidget {
  final Map<String, dynamic>? customer;
  final List<Map<String, dynamic>> sites;
  final bool isLoadingSites;
  final VoidCallback onSave;
  final String role; // Added role parameter

  const CustomerFormSheet({
    super.key,
    this.customer,
    required this.sites,
    required this.isLoadingSites,
    required this.onSave,
    required this.role,
  });

  @override
  _CustomerFormSheetState createState() => _CustomerFormSheetState();
}

class _CustomerFormSheetState extends State<CustomerFormSheet> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _idTypeController;
  late TextEditingController _idNumberController;
  late TextEditingController _tinNumberController;
  late TextEditingController _addressController;
  late TextEditingController _notesController;
  String? _selectedSiteId;
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.customer?['name'] ?? '');
    _emailController = TextEditingController(text: widget.customer?['email'] ?? '');
    _phoneController = TextEditingController(text: widget.customer?['phone'] ?? '');
    _idTypeController = TextEditingController(text: widget.customer?['id_type'] ?? '');
    _idNumberController = TextEditingController(text: widget.customer?['id_number'] ?? '');
    _tinNumberController = TextEditingController(text: widget.customer?['tin_number'] ?? '');
    _addressController = TextEditingController(text: widget.customer?['address'] ?? '');
    _notesController = TextEditingController(text: widget.customer?['notes'] ?? '');

    _selectedSiteId = widget.customer?['site_id']?.toString();
    if (_selectedSiteId != null && widget.sites.isNotEmpty) {
      final validSite = widget.sites.any((site) => site['id']?.toString() == _selectedSiteId);
      if (!validSite) {
        debugPrint('Invalid site_id: $_selectedSiteId not found in available sites');
        _selectedSiteId = null;
      }
    }
  }

  Future<Map<String, String>?> _getCurrentLocationAsString() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Location services are disabled. Please enable them.';
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permissions are denied.';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'Location permissions are permanently denied.';
      }

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      return {
        'latitude': position.latitude.toString(),
        'longitude': position.longitude.toString(),
      };
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to get location: $e', style: const TextStyle(fontFamily: 'Nunito', fontSize: 14))),
        );
      }
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  widget.customer == null ? 'Add Customer' : 'Edit Customer',
                  style: const TextStyle(fontFamily: 'Nunito', fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedSiteId,
                  decoration: InputDecoration(
                    labelText: 'Site',
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFDF0613), width: 1)),
                    prefixIcon: const Icon(Icons.location_on, color: Color(0xFFDF0613)),
                  ),
                  hint: widget.isLoadingSites
                      ? const Text('Loading sites...', style: TextStyle(fontFamily: 'Nunito', fontSize: 14))
                      : widget.sites.isEmpty
                          ? const Text('No sites available', style: TextStyle(fontFamily: 'Nunito', fontSize: 14))
                          : const Text('Select a site', style: TextStyle(fontFamily: 'Nunito', fontSize: 14)),
                  items: widget.sites.isNotEmpty
                      ? widget.sites.map((site) {
                          final siteId = site['id']?.toString();
                          return DropdownMenuItem<String>(
                            value: siteId,
                            child: Text(site['name'] ?? 'Unknown Site', style: const TextStyle(fontFamily: 'Nunito', fontSize: 14)),
                          );
                        }).toList()
                      : [
                          const DropdownMenuItem<String>(
                            value: null,
                            enabled: false,
                            child: Text('No sites available', style: TextStyle(fontFamily: 'Nunito', fontSize: 14, color: Colors.grey)),
                          ),
                        ],
                  onChanged: widget.isLoadingSites || widget.sites.isEmpty ? null : (value) => setState(() => _selectedSiteId = value),
                  validator: (value) => value == null && widget.sites.isNotEmpty ? 'Please select a site' : null,
                ),
                const SizedBox(height: 12),
                _buildTextFormField(controller: _nameController, label: 'Name', icon: Icons.person, validator: (value) => value!.isEmpty ? 'Enter name' : null),
                const SizedBox(height: 12),
                _buildTextFormField(controller: _emailController, label: 'Email', icon: Icons.email, keyboardType: TextInputType.emailAddress, validator: (value) => value!.isEmpty ? 'Enter email' : null),
                const SizedBox(height: 12),
                _buildTextFormField(controller: _phoneController, label: 'Phone', icon: Icons.phone, keyboardType: TextInputType.phone, validator: (value) => value!.isEmpty ? 'Enter phone' : null),
                const SizedBox(height: 12),
                _buildTextFormField(controller: _addressController, label: 'Address', icon: Icons.home, validator: (value) => value!.isEmpty ? 'Enter address' : null),
                const SizedBox(height: 12),
                _buildTextFormField(controller: _idTypeController, label: 'ID Type', icon: Icons.badge),
                const SizedBox(height: 12),
                _buildTextFormField(controller: _idNumberController, label: 'ID Number', icon: Icons.badge),
                const SizedBox(height: 12),
                _buildTextFormField(controller: _tinNumberController, label: 'TIN Number', icon: Icons.numbers),
                const SizedBox(height: 12),
                _buildTextFormField(controller: _notesController, label: 'Notes', icon: Icons.note, maxLines: 3),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isSaving || widget.role == 'installer' // Disable button for installers
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() => _isSaving = true);

                            final location = await _getCurrentLocationAsString();

                            if (widget.customer == null && location == null) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not create customer: Location is required.', style: TextStyle(fontFamily: 'Nunito', fontSize: 14))));
                                setState(() => _isSaving = false);
                              }
                              return;
                            }

                            final customerData = {
                              'site_id': _selectedSiteId,
                              'name': _nameController.text,
                              'email': _emailController.text,
                              'phone': _phoneController.text,
                              'address': _addressController.text,
                              'id_type': _idTypeController.text,
                              'id_number': _idNumberController.text,
                              'tin_number': _tinNumberController.text,
                              'notes': _notesController.text,
                              if (location != null) 'latitude': location['latitude'],
                              if (location != null) 'longitude': location['longitude'],
                            };

                            try {
                              String? customerId;
                              if (widget.customer == null) {
                                final response = await ApiService.createCustomer(customerData);
                                customerId = response['id']?.toString();
                              } else {
                                await ApiService.updateCustomer(widget.customer!['id'].toString(), customerData);
                                customerId = widget.customer!['id'].toString();
                              }

                              if (mounted) {
                                Navigator.pop(context); // Close the bottom sheet
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Customer ${widget.customer == null ? 'added' : 'updated'} successfully', style: const TextStyle(fontFamily: 'Nunito', fontSize: 14))),
                                );
                                widget.onSave(); // Refresh the customer list

                                // Navigate to TicketFormScreen for DSE users
                                if (widget.role == 'dse' && customerId != null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => TicketFormScreen(customerId: customerId)),
                                  ).then((_) => widget.onSave()); // Refresh again after returning
                                }
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: $e', style: const TextStyle(fontFamily: 'Nunito', fontSize: 14))),
                                );
                              }
                            } finally {
                              if (mounted) {
                                setState(() => _isSaving = false);
                              }
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    backgroundColor: const Color(0xFFDF0613),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 3)
                      : Text(
                          widget.customer == null ? 'Add Customer' : 'Update Customer',
                          style: const TextStyle(fontFamily: 'Nunito', fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(fontFamily: 'Nunito', fontSize: 14, color: Color(0xFFDF0613), fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFDF0613), width: 1)),
        prefixIcon: Icon(icon, color: const Color(0xFFDF0613)),
      ),
      keyboardType: keyboardType,
      style: const TextStyle(fontFamily: 'Nunito', fontSize: 14),
      validator: validator,
      maxLines: maxLines,
      enabled: widget.role == 'dse', // Disable fields for installers (though they shouldn't reach here)
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _idTypeController.dispose();
    _idNumberController.dispose();
    _tinNumberController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}