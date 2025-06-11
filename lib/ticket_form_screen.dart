// lib/ticket_form_screen.dart (Refined)
import 'package:flutter/material.dart';
import 'package:untitled1/api_service.dart';

class TicketFormScreen extends StatefulWidget {
  final Map<String, dynamic>? ticket;
  final String? customerId;

  const TicketFormScreen({super.key, this.ticket, this.customerId});

  @override
  _TicketFormScreenState createState() => _TicketFormScreenState();
}

class _TicketFormScreenState extends State<TicketFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _notesController;

  // --- State Variables for Dropdowns ---
  String? _selectedCustomerId;
  String? _selectedServiceTypeId;
  String? _selectedDeviceTypeId; // NEW: State for Device Type

  // --- Data Lists for Dropdowns ---
  List<Map<String, dynamic>> _customers = [];
  List<Map<String, dynamic>> _serviceTypes = [];
  List<Map<String, dynamic>> _deviceTypes = []; // NEW: List for Device Types

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.ticket?['notes'] ?? '');
    
    // Initialize selected values from the existing ticket data if available
    _selectedCustomerId = widget.ticket?['customer']?['id']?.toString() ?? widget.customerId;
    _selectedServiceTypeId = widget.ticket?['service_type']?['id']?.toString();
    _selectedDeviceTypeId = widget.ticket?['device_type']?['id']?.toString(); // NEW: Initialize Device Type
    
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Use Future.wait to fetch all data in parallel for better performance
      final results = await Future.wait([
        ApiService.getCustomers(),
        ApiService.getServiceTypes(),
        ApiService.getDeviceTypes(), // NEW: Fetch device types
      ]);
      
      if (mounted) {
        setState(() {
          _customers = results[0];
          _serviceTypes = results[1];
          _deviceTypes = results[2]; // NEW: Assign fetched device types
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load data: $e', style: const TextStyle(fontFamily: 'Nunito', fontSize: 14))),
        );
      }
    }
  }

  Future<void> _saveTicket() async {
    if (!_formKey.currentState!.validate()) {
      return; // If form is not valid, do nothing.
    }
    
    setState(() => _isSaving = true);

    final ticketData = {
      'customer_id': _selectedCustomerId,
      'service_type_id': _selectedServiceTypeId,
      'device_type_id': _selectedDeviceTypeId, // NEW: Add device_type_id to the payload
      if (_notesController.text.isNotEmpty) 'notes': _notesController.text,
    };

    try {
      if (widget.ticket == null) {
        await ApiService.createTicket(ticketData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ticket created successfully', style: TextStyle(fontFamily: 'Nunito'))),
          );
        }
      } else {
        await ApiService.updateTicket(widget.ticket!['id'].toString(), ticketData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ticket updated successfully', style: TextStyle(fontFamily: 'Nunito'))),
          );
        }
      }
      if (mounted) {
        Navigator.pop(context, true); // Pop and signal a refresh
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e', style: const TextStyle(fontFamily: 'Nunito'))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFDF0613);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.ticket == null ? 'Create Ticket' : 'Edit Ticket',
          style: const TextStyle(color: Colors.white, fontSize: 18, fontFamily: 'Nunito', fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Customer Dropdown
                      _buildDropdown(
                        label: 'Customer',
                        icon: Icons.person,
                        value: _selectedCustomerId,
                        items: _customers,
                        hint: 'Select a customer',
                        onChanged: (value) => setState(() => _selectedCustomerId = value),
                        itemBuilder: (customer) => DropdownMenuItem<String>(
                          value: customer['id']?.toString(),
                          child: Text(
                            '${customer['name'] ?? 'Unknown'} (${customer['site']?['name'] ?? 'No site'})',
                            style: const TextStyle(fontFamily: 'Nunito', fontSize: 14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Service Type Dropdown
                      _buildDropdown(
                        label: 'Service Type',
                        icon: Icons.build,
                        value: _selectedServiceTypeId,
                        items: _serviceTypes,
                        hint: 'Select a service type',
                        onChanged: (value) => setState(() => _selectedServiceTypeId = value),
                        itemBuilder: (service) => DropdownMenuItem<String>(
                          value: service['id']?.toString(),
                          child: Text(service['name'] ?? 'Unknown Service', style: const TextStyle(fontFamily: 'Nunito', fontSize: 14)),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // [NEW] Device Type Dropdown
                      _buildDropdown(
                        label: 'Device Type',
                        icon: Icons.devices_other,
                        value: _selectedDeviceTypeId,
                        items: _deviceTypes,
                        hint: 'Select a device type',
                        onChanged: (value) => setState(() => _selectedDeviceTypeId = value),
                        itemBuilder: (device) => DropdownMenuItem<String>(
                          value: device['id']?.toString(),
                          child: Text(device['name'] ?? 'Unknown Device', style: const TextStyle(fontFamily: 'Nunito', fontSize: 14)),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Notes Text Field
                      TextFormField(
                        controller: _notesController,
                        decoration: _inputDecoration('Notes (Optional)', Icons.note),
                        style: const TextStyle(fontFamily: 'Nunito', fontSize: 14),
                        maxLines: 4,
                      ),
                      const SizedBox(height: 24),

                      // Submit Button
                      ElevatedButton(
                        onPressed: _isSaving ? null : _saveTicket,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                              )
                            : Text(
                                widget.ticket == null ? 'Create Ticket' : 'Update Ticket',
                                style: const TextStyle(fontFamily: 'Nunito', fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                      ),
                      const SizedBox(height: 8),

                      // Cancel Button
                      Center(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(fontFamily: 'Nunito', fontSize: 14, color: primaryColor, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  // Helper method to build consistent dropdowns
  Widget _buildDropdown({
    required String label,
    required IconData icon,
    required String? value,
    required List<Map<String, dynamic>> items,
    required String hint,
    required void Function(String?) onChanged,
    required DropdownMenuItem<String> Function(Map<String, dynamic>) itemBuilder,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: _inputDecoration(label, icon),
      hint: Text(hint, style: const TextStyle(fontFamily: 'Nunito', fontSize: 14)),
      items: items.map(itemBuilder).toList(),
      onChanged: items.isEmpty ? null : onChanged,
      validator: (val) => val == null && items.isNotEmpty ? 'Please select an option' : null,
    );
  }

  // Helper method for consistent input decoration
  InputDecoration _inputDecoration(String label, IconData icon) {
    const primaryColor = Color(0xFFDF0613);
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontFamily: 'Nunito'),
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryColor, width: 1.5)),
      prefixIcon: Icon(icon, color: primaryColor),
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
}