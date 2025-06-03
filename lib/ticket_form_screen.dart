import 'package:flutter/material.dart';
import 'package:untitled1/api_service.dart';

import 'home_screen.dart';

class TicketFormScreen extends StatefulWidget {
  final Map<String, dynamic>? ticket;
  final String? customerId;

  const TicketFormScreen({super.key, this.ticket, this.customerId});

  @override
  _TicketFormScreenState createState() => _TicketFormScreenState();
}

class _TicketFormScreenState extends State<TicketFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedCustomerId;
  String? _selectedSiteId;
  String? _selectedStatus;
  String? _selectedType;
  List<Map<String, dynamic>> _customers = [];
  List<Map<String, dynamic>> _sites = [];
  List<Map<String, dynamic>> _serviceTypes = [];

  @override
  void initState() {
    super.initState();
    if (widget.ticket != null) {
      _titleController.text = widget.ticket!['title'] ?? '';
      _descriptionController.text = widget.ticket!['description'] ?? '';
      _selectedCustomerId = widget.ticket!['customer_id'];
      _selectedSiteId = widget.ticket!['site_id'];
      _selectedStatus = widget.ticket!['status'];
      _selectedType = widget.ticket!['type'];
    } else if (widget.customerId != null) {
      _selectedCustomerId = widget.customerId;
    }
    _loadData();
  }

  void _loadData() async {
    try {
      _customers = await ApiService.getCustomers();
      _sites = await ApiService.getSites();
      _serviceTypes = await ApiService.getServiceTypes();
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e', style: const TextStyle(fontSize: 14))),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _showActionSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      builder: (context) => DraggableScrollableSheet(
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
                    widget.ticket == null ? 'Add Ticket' : 'Edit Ticket',
                    style: const TextStyle(fontFamily: 'Nunito', fontSize: 16),
                  ),
                  const SizedBox(height: 12),
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
                        child: Text(customer['name'] ?? 'Unknown', style: const TextStyle(fontSize: 14)),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedCustomerId = value),
                    style: const TextStyle(fontSize: 14),
                    validator: (value) => value == null ? 'Select a customer' : null,
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
                    onChanged: (value) => setState(() => _selectedSiteId = value),
                    style: const TextStyle(fontSize: 14),
                    validator: (value) => value == null ? 'Select a site' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.title, color: Color(0xFFDF0613)),
                    ),
                    style: const TextStyle(fontSize: 14),
                    validator: (value) => value!.isEmpty ? 'Enter title' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description, color: Color(0xFFDF0613)),
                    ),
                    maxLines: 3,
                    style: const TextStyle(fontSize: 14),
                    validator: (value) => value!.isEmpty ? 'Enter description' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.info_outline, color: Color(0xFFDF0613)),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'open', child: Text('Open', style: TextStyle(fontSize: 14))),
                      DropdownMenuItem(value: 'in_progress', child: Text('In Progress', style: TextStyle(fontSize: 14))),
                      DropdownMenuItem(value: 'closed', child: Text('Closed', style: TextStyle(fontSize: 14))),
                    ],
                    onChanged: (value) => setState(() => _selectedStatus = value),
                    style: const TextStyle(fontSize: 14),
                    validator: (value) => value == null ? 'Select a status' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Type',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.category, color: Color(0xFFDF0613)),
                    ),
                    items: _serviceTypes.map((type) {
                      return DropdownMenuItem<String>(
                        value: type['id'],
                        child: Text(type['name'] ?? 'Unknown', style: const TextStyle(fontSize: 14)),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedType = value),
                    style: const TextStyle(fontSize: 14),
                    validator: (value) => value == null ? 'Select a type' : null,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final ticketData = {
                          'title': _titleController.text,
                          'description': _descriptionController.text,
                          'customer_id': _selectedCustomerId,
                          'site_id': _selectedSiteId,
                          'status': _selectedStatus,
                          'type': _selectedType,
                        };
                        try {
                          if (widget.ticket == null) {
                            await ApiService.createTicket(ticketData);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Ticket created', style: TextStyle(fontSize: 14))),
                            );
                          } else {
                            await ApiService.updateTicket(widget.ticket!['id'], ticketData);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Ticket updated', style: TextStyle(fontSize: 14))),
                            );
                          }
                          Navigator.pop(context);
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
                    child: Text(widget.ticket == null ? 'Create' : 'Update', style: const TextStyle(fontSize: 14)),
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
      ),
    );
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
      ),
      body: _customers.isEmpty || _sites.isEmpty || _serviceTypes.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        ElevatedButton(
                          onPressed: _showActionSheet,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                          ),
                          child: Text(
                            widget.ticket == null ? 'Fill Ticket Details' : 'Edit Ticket Details',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12),
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
      ),
    );
  }
}