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
  String? _selectedCustomerId;
  String? _selectedServiceTypeId;
  List<Map<String, dynamic>> _customers = [];
  List<Map<String, dynamic>> _serviceTypes = [];
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.ticket?['notes'] ?? '');
    _selectedCustomerId = widget.ticket?['customer']?['id']?.toString() ?? widget.customerId;
    _selectedServiceTypeId = widget.ticket?['service_type']?['id']?.toString();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final customers = await ApiService.getCustomers();
      final serviceTypes = await ApiService.getServiceTypes();
      if (mounted) {
        setState(() {
          _customers = customers;
          _serviceTypes = serviceTypes;
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

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFDF0613);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.ticket == null ? 'Create Ticket' : 'Edit Ticket',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontFamily: 'Nunito',
            fontWeight: FontWeight.bold,
          ),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<String>(
                        value: _selectedCustomerId,
                        decoration: InputDecoration(
                          labelText: 'Customer',
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFDF0613), width: 1)),
                          prefixIcon: const Icon(Icons.person, color: Color(0xFFDF0613)),
                        ),
                        hint: _customers.isEmpty
                            ? const Text('No customers available', style: TextStyle(fontFamily: 'Nunito', fontSize: 14))
                            : const Text('Select a customer', style: TextStyle(fontFamily: 'Nunito', fontSize: 14)),
                        items: _customers.isNotEmpty
                            ? _customers.map((customer) {
                                final customerId = customer['id']?.toString();
                                return DropdownMenuItem<String>(
                                  value: customerId,
                                  child: Text(
                                    '${customer['name'] ?? 'Unknown'} (${customer['site']?['name'] ?? 'No site'})',
                                    style: const TextStyle(fontFamily: 'Nunito', fontSize: 14),
                                  ),
                                );
                              }).toList()
                            : [
                                const DropdownMenuItem<String>(
                                  value: null,
                                  enabled: false,
                                  child: Text('No customers available', style: TextStyle(fontFamily: 'Nunito', fontSize: 14, color: Colors.grey)),
                                ),
                              ],
                        onChanged: _customers.isEmpty ? null : (value) => setState(() => _selectedCustomerId = value),
                        validator: (value) => value == null && _customers.isNotEmpty ? 'Please select a customer' : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _selectedServiceTypeId,
                        decoration: InputDecoration(
                          labelText: 'Service Type',
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFDF0613), width: 1)),
                          prefixIcon: const Icon(Icons.build, color: Color(0xFFDF0613)),
                        ),
                        hint: _serviceTypes.isEmpty
                            ? const Text('No service types available', style: TextStyle(fontFamily: 'Nunito', fontSize: 14))
                            : const Text('Select a service type', style: TextStyle(fontFamily: 'Nunito', fontSize: 14)),
                        items: _serviceTypes.isNotEmpty
                            ? _serviceTypes.map((service) {
                                final serviceId = service['id']?.toString();
                                return DropdownMenuItem<String>(
                                  value: serviceId,
                                  child: Text(service['name'] ?? 'Unknown Service', style: const TextStyle(fontFamily: 'Nunito', fontSize: 14)),
                                );
                              }).toList()
                            : [
                                const DropdownMenuItem<String>(
                                  value: null,
                                  enabled: false,
                                  child: Text('No service types available', style: TextStyle(fontFamily: 'Nunito', fontSize: 14, color: Colors.grey)),
                                ),
                              ],
                        onChanged: _serviceTypes.isEmpty ? null : (value) => setState(() => _selectedServiceTypeId = value),
                        validator: (value) => value == null && _serviceTypes.isNotEmpty ? 'Please select a service type' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _notesController,
                        decoration: InputDecoration(
                          labelText: 'Notes (Optional)',
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFDF0613), width: 1)),
                          prefixIcon: const Icon(Icons.note, color: Color(0xFFDF0613)),
                        ),
                        style: const TextStyle(fontFamily: 'Nunito', fontSize: 14),
                        maxLines: 4,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _isSaving
                            ? null
                            : () async {
                                if (_formKey.currentState!.validate()) {
                                  setState(() => _isSaving = true);
                                  final ticketData = {
                                    'customer_id': _selectedCustomerId,
                                    'service_type_id': _selectedServiceTypeId,
                                    if (_notesController.text.isNotEmpty) 'notes': _notesController.text,
                                  };
                                  try {
                                    if (widget.ticket == null) {
                                      await ApiService.createTicket(ticketData);
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Ticket created successfully', style: TextStyle(fontFamily: 'Nunito', fontSize: 14)),
                                          ),
                                        );
                                      }
                                    } else {
                                      await ApiService.updateTicket(widget.ticket!['id'].toString(), ticketData);
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Ticket updated successfully', style: TextStyle(fontFamily: 'Nunito', fontSize: 14)),
                                          ),
                                        );
                                      }
                                    }
                                    if (mounted) {
                                      Navigator.pop(context);
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
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isSaving
                            ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 3)
                            : Text(
                                widget.ticket == null ? 'Create Ticket' : 'Update Ticket',
                                style: const TextStyle(fontFamily: 'Nunito', fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(fontFamily: 'Nunito', fontSize: 14, color: Color(0xFFDF0613), fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
}