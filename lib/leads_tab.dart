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
  List<Map<String, dynamic>> _filteredLeads = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoadingSites = true;

  @override
  void initState() {
    super.initState();
    _leadsFuture = _fetchLeads();
    _loadSites();
    _searchController.addListener(_filterLeads);
  }

  Future<List<Map<String, dynamic>>> _fetchLeads() async {
    try {
      final leads = await ApiService.getLeads();
      _filteredLeads = leads; // Initialize filtered list
      return leads;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load leads: $e', style: const TextStyle(fontFamily: 'Nunito', fontSize: 14)),
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

  void _filterLeads() {
    _leadsFuture.then((leads) {
      final query = _searchController.text.toLowerCase();
      setState(() {
        _filteredLeads = leads.where((lead) {
          final name = lead['name']?.toLowerCase() ?? '';
          final email = lead['email']?.toLowerCase() ?? '';
          final phone = lead['phone']?.toLowerCase() ?? '';
          return name.contains(query) || email.contains(query) || phone.contains(query);
        }).toList();
      });
    });
  }

  void _refreshLeads() {
    setState(() {
      _leadsFuture = _fetchLeads();
      _filterLeads();
    });
  }

  void _showLeadActionSheet(BuildContext context, Map<String, dynamic>? lead) {
    final _nameController = TextEditingController(text: lead?['name'] ?? '');
    final _emailController = TextEditingController(text: lead?['email'] ?? '');
    final _phoneController = TextEditingController(text: lead?['phone'] ?? '');
    final _notesController = TextEditingController(text: lead?['notes'] ?? '');
    String? _selectedSiteId = lead?['site_id']?.toString();
    final _formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (BuildContext context, StateSetter modalSetState) {
          return DraggableScrollableSheet(
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lead == null ? 'Add Lead' : 'Edit Lead',
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
                        controller: _notesController,
                        label: 'Notes',
                        icon: Icons.note,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
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
                                await ApiService.updateLead(lead['id'].toString(), leadData);
                              }
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Lead ${lead == null ? 'added' : 'updated'} successfully',
                                    style: const TextStyle(fontFamily: 'Nunito', fontSize: 14),
                                  ),
                                ),
                              );
                              _refreshLeads();
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
                          lead == null ? 'Add Lead' : 'Update Lead',
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
          'Leads',
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
                    _filterLeads();
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
              future: _leadsFuture,
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
                          'Failed to load leads',
                          style: TextStyle(fontFamily: 'Nunito', fontSize: 14),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _refreshLeads,
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
                final leads = snapshot.data ?? [];
                if (_filteredLeads.isEmpty && _searchController.text.isNotEmpty) {
                  return const Center(
                    child: Text(
                      'No matching leads',
                      style: TextStyle(fontFamily: 'Nunito', fontSize: 14),
                    ),
                  );
                }
                if (_filteredLeads.isEmpty && leads.isEmpty) {
                  return const Center(
                    child: Text(
                      'No leads available',
                      style: TextStyle(fontFamily: 'Nunito', fontSize: 14),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _filteredLeads.length,
                  itemBuilder: (context, index) {
                    final lead = _filteredLeads[index];
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
                            lead['name']?.isNotEmpty == true ? lead['name'][0].toUpperCase() : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'Nunito',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          lead['name'] ?? 'Unknown',
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        subtitle: Text(
                          '${lead['email'] ?? 'No email'} | ${lead['phone'] ?? 'No phone'}',
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
                              onPressed: () => _showLeadActionSheet(context, lead),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red, size: 24),
                              onPressed: () => _deleteLead(context, lead['id']),
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
                MaterialPageRoute(builder: (context) => const HomeScreen(username: 'Guest', role: '',)),
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
        onPressed: () => _showLeadActionSheet(context, null),
        child: const Icon(Icons.add, size: 24, color: Colors.white),
      ),
    );
  }

  Future<void> _deleteLead(BuildContext context, String? leadId) async {
    if (leadId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid lead ID', style: TextStyle(fontFamily: 'Nunito', fontSize: 14)),
        ),
      );
      return;
    }
    try {
      await ApiService.deleteLead(leadId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lead deleted successfully', style: TextStyle(fontFamily: 'Nunito', fontSize: 14)),
        ),
      );
      _refreshLeads();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete lead: $e', style: const TextStyle(fontFamily: 'Nunito', fontSize: 14)),
        ),
      );
    }
  }
}