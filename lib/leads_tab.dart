import 'package:flutter/material.dart';
import 'package:untitled1/api_service.dart';
import 'package:untitled1/home_screen.dart';

class LeadsTab extends StatefulWidget {
  const LeadsTab({super.key});

  @override
  _LeadsTabState createState() => _LeadsTabState();
}

class _LeadsTabState extends State<LeadsTab> {
  late Future<List<Map<String, dynamic>>> _leadsFuture;
  List<Map<String, dynamic>> _sites = [];

  @override
  void initState() {
    super.initState();
    _leadsFuture = ApiService.getLeads();
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

  void _showLeadActionSheet(BuildContext context, Map<String, dynamic>? lead) {
    final _nameController = TextEditingController(text: lead?['name'] ?? '');
    final _emailController = TextEditingController(text: lead?['email'] ?? '');
    final _phoneController = TextEditingController(text: lead?['phone'] ?? '');
    final _notesController = TextEditingController(text: lead?['notes'] ?? '');
    String? _selectedSiteId = lead?['site_id'];
    final _formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
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
                    lead == null ? 'Add Lead' : 'Edit Lead',
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
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notes',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.note, color: Color(0xFFDF0613)),
                    ),
                    maxLines: 3,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final leadData = {
                          'site_id': _selectedSiteId,
                          'name': _nameController.text,
                          'email': _emailController.text,
                          'phone': _phoneController.text,
                          'notes': _notesController.text,
                        };
                        try {
                          if (lead == null) {
                            await ApiService.createLead(leadData);
                          } else {
                            await ApiService.updateLead(lead['id'], leadData);
                          }
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Lead ${lead == null ? 'added' : 'updated'}', style: const TextStyle(fontSize: 14))),
                          );
                          setState(() {
                            _leadsFuture = ApiService.getLeads();
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
                    child: Text(lead == null ? 'Add' : 'Update', style: const TextStyle(fontSize: 14)),
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
        title: const Text('Leads', style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Nunito')),
        backgroundColor: const Color(0xFFDF0613),
        // Add this line to make the back arrow (and other AppBar icons) white
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _leadsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading leads', style: TextStyle(fontFamily: 'Nunito', fontSize: 14)));
                }
                final leads = snapshot.data ?? [];
                if (leads.isEmpty) {
                  return const Center(
                    child: Text('No leads', style: TextStyle(fontFamily: 'Nunito', fontSize: 14)),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: leads.length,
                  itemBuilder: (context, index) {
                    final lead = leads[index];
                    return Card(
                      elevation: 1,
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFFDF0613),
                          child: Text(
                            lead['name']?.isNotEmpty == true ? lead['name'][0] : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'Nunito',
                              fontSize: 14,
                            ),
                          ),
                        ),
                        title: Text(
                          lead['name'] ?? 'Unknown',
                          style: const TextStyle(fontFamily: 'Nunito', fontSize: 14),
                        ),
                        subtitle: Text(
                          '${lead['email'] ?? ''} | ${lead['phone'] ?? ''}',
                          style: const TextStyle(fontFamily: 'Nunito', fontSize: 12),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Color(0xFFDF0613), size: 20),
                              onPressed: () => _showLeadActionSheet(context, lead),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                              onPressed: () async {
                                try {
                                  await ApiService.deleteLead(lead['id']);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Lead deleted', style: TextStyle(fontSize: 14))),
                                  );
                                  setState(() {
                                    _leadsFuture = ApiService.getLeads();
                                  });
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error: $e', style: const TextStyle(fontSize: 14))),
                                  );
                                }
                              },
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
        onPressed: () => _showLeadActionSheet(context, null),
      ),
    );
  }
}