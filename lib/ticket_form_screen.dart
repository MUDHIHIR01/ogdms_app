import 'package:flutter/material.dart';
import 'package:untitled1/api_service.dart';
import 'package:untitled1/home_screen.dart';
import 'package:intl/intl.dart';

class TicketFormScreen extends StatefulWidget {
  final Map<String, dynamic>? ticket;
  final String? customerId;

  const TicketFormScreen({super.key, this.ticket, this.customerId});

  @override
  _TicketFormScreenState createState() => _TicketFormScreenState();
}

class _TicketFormScreenState extends State<TicketFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedCustomerId;
  String? _selectedServiceTypeId;
  String? _selectedDeviceTypeId;
  String? _installerId;
  String? _complaintId;
  DateTime? _scheduledAt;
  List<Map<String, dynamic>> _customers = [];
  List<Map<String, dynamic>> _serviceTypes = [];
  List<Map<String, dynamic>> _deviceTypes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.ticket != null) {
      _selectedCustomerId = widget.ticket!['customer_id'];
      _selectedServiceTypeId = widget.ticket!['service_type_id'];
      _selectedDeviceTypeId = widget.ticket!['device_type_id'];
      _installerId = widget.ticket!['installer_id'];
      _complaintId = widget.ticket!['complaint_id'];
      _scheduledAt = widget.ticket!['scheduled_at'] != null
          ? DateTime.parse(widget.ticket!['scheduled_at'])
          : null;
    } else if (widget.customerId != null) {
      _selectedCustomerId = widget.customerId;
    }
    _loadData();
  }

  void _loadData() async {
    try {
      _customers = await ApiService.getCustomers();
      _serviceTypes = await ApiService.getServiceTypes();
      _deviceTypes = await ApiService.getDeviceTypes();
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e', style: const TextStyle(fontSize: 14))),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _scheduledAt ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _scheduledAt) {
      setState(() => _scheduledAt = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.ticket == null ? 'Create Ticket' : 'Edit Ticket',
          style: const TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Nunito'),
        ),
        backgroundColor: const Color(0xFFDF0613),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFDF0613)))
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedCustomerId,
                  decoration: const InputDecoration(
                    labelText: 'Customer',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person, color: Color(0xFFDF0613)),
                  ),
                  items: _customers.map((customer) {
                    return DropdownMenuItem<String>(
                      value: customer['id'],
                      child: Text(
                        '${customer['name'] ?? 'Unknown'} (${customer['site']?['name'] ?? 'No site'})',
                        style: const TextStyle(fontSize: 14),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedCustomerId = value),
                  validator: (value) => value == null ? 'Please select a customer' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedServiceTypeId,
                  decoration: const InputDecoration(
                    labelText: 'Service Type',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.build, color: Color(0xFFDF0613)),
                  ),
                  items: _serviceTypes.map((serviceType) {
                    return DropdownMenuItem<String>(
                      value: serviceType['id'],
                      child: Text(serviceType['name'] ?? 'Unknown', style: const TextStyle(fontSize: 14)),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedServiceTypeId = value),
                  validator: (value) => value == null ? 'Please select a service type' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedDeviceTypeId,
                  decoration: const InputDecoration(
                    labelText: 'Device Type (Optional)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.devices, color: Color(0xFFDF0613)),
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('None', style: TextStyle(fontSize: 14)),
                    ),
                    ..._deviceTypes.map((deviceType) {
                      return DropdownMenuItem<String>(
                        value: deviceType['id'],
                        child: Text(deviceType['name'] ?? 'Unknown', style: const TextStyle(fontSize: 14)),
                      );
                    }),
                  ],
                  onChanged: (value) => setState(() => _selectedDeviceTypeId = value),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _installerId,
                  decoration: const InputDecoration(
                    labelText: 'Installer ID (Optional)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person_add, color: Color(0xFFDF0613)),
                  ),
                  onChanged: (value) => _installerId = value.isEmpty ? null : value,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _complaintId,
                  decoration: const InputDecoration(
                    labelText: 'Complaint ID (Optional)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.report, color: Color(0xFFDF0613)),
                  ),
                  onChanged: (value) => _complaintId = value.isEmpty ? null : value,
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () => _selectDate(context),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Scheduled At (Optional)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_today, color: Color(0xFFDF0613)),
                    ),
                    child: Text(
                      _scheduledAt == null
                          ? 'Select date'
                          : DateFormat('yyyy-MM-dd').format(_scheduledAt!),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final ticketData = {
                        'customer_id': _selectedCustomerId,
                        'service_type_id': _selectedServiceTypeId,
                        if (_selectedDeviceTypeId != null) 'device_type_id': _selectedDeviceTypeId,
                        if (_installerId != null) 'installer_id': _installerId,
                        if (_complaintId != null) 'complaint_id': _complaintId,
                        if (_scheduledAt != null)
                          'scheduled_at': _scheduledAt!.toIso8601String(),
                      };
                      try {
                        if (widget.ticket == null) {
                          await ApiService.createTicket(ticketData);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Ticket created successfully',
                                    style: TextStyle(fontSize: 14))),
                          );
                        } else {
                          await ApiService.updateTicket(widget.ticket!['id'], ticketData);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Ticket updated successfully',
                                    style: TextStyle(fontSize: 14))),
                          );
                        }
                        Navigator.pop(context);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Error: $e', style: const TextStyle(fontSize: 14))),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    backgroundColor: const Color(0xFFDF0613),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    widget.ticket == null ? 'Create Ticket' : 'Update Ticket',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel',
                      style: TextStyle(fontSize: 14, color: Color(0xFFDF0613))),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Back to Home', style: TextStyle(fontSize: 14)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}