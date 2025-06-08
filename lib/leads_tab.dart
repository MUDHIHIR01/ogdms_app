import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Make sure you have this in pubspec.yaml
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
  List<Map<String, dynamic>> _allLeads = []; // Store the master list of leads
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
      await _loadSites();
      if (mounted) {
        setState(() {
          _allLeads = leads; // Update the master list
          _filteredLeads = leads; // Initially, filtered list is the full list
          _filterLeads(); // Apply any existing search query
        });
      }
      return leads;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load leads: $e', style: const TextStyle(fontFamily: 'Nunito', fontSize: 14))),
        );
      }
      return [];
    }
  }

  Future<void> _loadSites() async {
    if (!_isLoadingSites && _sites.isNotEmpty) return;
    try {
      _sites = await ApiService.getSites();
      if (mounted) {
        setState(() {
          _isLoadingSites = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingSites = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load sites: $e', style: const TextStyle(fontFamily: 'Nunito', fontSize: 14))),
        );
      }
    }
  }

  void _filterLeads() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredLeads = _allLeads.where((lead) {
        final name = lead['name']?.toLowerCase() ?? '';
        final email = lead['email']?.toLowerCase() ?? '';
        final phone = lead['phone']?.toLowerCase() ?? '';
        return name.contains(query) || email.contains(query) || phone.contains(query);
      }).toList();
    });
  }

  void _refreshLeads() {
    setState(() {
      _searchController.clear(); // Clear search on refresh
      _leadsFuture = _fetchLeads();
    });
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontFamily: 'Nunito', fontSize: 13.5, color: Colors.black54),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'N/A';
    try {
      final dateTime = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy').format(dateTime);
    } catch (e) {
      return 'Invalid Date';
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFDF0613);
    const backgroundColor = Colors.white;
    const cardColor = Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Leads', style: TextStyle(color: Colors.white, fontSize: 18, fontFamily: 'Nunito', fontWeight: FontWeight.bold)),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Search Bar
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
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear, color: primaryColor),
                  onPressed: () => _searchController.clear(),
                )
                    : null,
              ),
              style: const TextStyle(fontFamily: 'Nunito', fontSize: 14, color: Colors.black87),
            ),
          ),
          // Leads List
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _leadsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting || _isLoadingSites) {
                  return const Center(child: CircularProgressIndicator(color: primaryColor));
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Failed to load leads: ${snapshot.error}', style: const TextStyle(fontFamily: 'Nunito')));
                }
                if (_filteredLeads.isEmpty) {
                  return Center(child: Text(_searchController.text.isNotEmpty ? 'No matching leads found' : 'No leads available', style: const TextStyle(fontFamily: 'Nunito')));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: _filteredLeads.length,
                  itemBuilder: (context, index) {
                    final lead = _filteredLeads[index];
                    final site = _sites.firstWhere(
                          (s) => s['id'] == lead['site_id'],
                      orElse: () => <String, dynamic>{},
                    );

                    final leadName = lead['name'] ?? 'Unknown Lead';
                    final phone = lead['phone'] ?? 'N/A';
                    final email = lead['email'] ?? 'N/A';
                    final siteName = site['name'] ?? 'Unknown Site';
                    final siteId = site['site_id']?.toString() ?? 'N/A';
                    final clusterName = site['cluster']?['name'] ?? 'Unknown Cluster';
                    final notes = lead['notes'] != null && lead['notes'].isNotEmpty ? lead['notes'] : 'No notes provided';
                    final createdAt = _formatDate(lead['created_at']);

                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      color: cardColor,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              backgroundColor: primaryColor,
                              child: Text(
                                leadName.isNotEmpty ? leadName[0].toUpperCase() : '?',
                                style: const TextStyle(color: Colors.white, fontFamily: 'Nunito', fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    leadName,
                                    style: const TextStyle(fontFamily: 'Nunito', fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black87),
                                  ),
                                  const SizedBox(height: 4),
                                  _buildInfoRow('Phone', phone),
                                  _buildInfoRow('Email', email),
                                  _buildInfoRow('Cluster', clusterName),
                                  _buildInfoRow('Site', '$siteName ($siteId)'),
                                  _buildInfoRow('Notes', notes),
                                  _buildInfoRow('Created', createdAt),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 36,
                                  width: 36,
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: const Icon(Icons.edit, color: primaryColor, size: 22),
                                    onPressed: () => _showLeadActionSheet(context, lead),
                                  ),
                                ),
                                SizedBox(
                                  height: 36,
                                  width: 36,
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: const Icon(Icons.delete, color: Colors.red, size: 22),
                                    // UPDATED: Pass ID as a string for type safety
                                    onPressed: () => _deleteLead(context, lead['id']?.toString()),
                                  ),
                                ),
                              ],
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
          // Back Button
          Padding(
            padding: const EdgeInsets.all(12),
            child: ElevatedButton(
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen(username: 'Guest', role: '')),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                backgroundColor: Colors.grey[300],
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Back to Home', style: TextStyle(fontFamily: 'Nunito', fontSize: 14, fontWeight: FontWeight.w600)),
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
                      Text(lead == null ? 'Add Lead' : 'Edit Lead', style: const TextStyle(fontFamily: 'Nunito', fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedSiteId,
                        decoration: InputDecoration(
                          labelText: 'Site',
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          prefixIcon: const Icon(Icons.location_on, color: Color(0xFFDF0613)),
                        ),
                        hint: _isLoadingSites ? const Text('Loading sites...') : const Text('Select a site'),
                        items: _sites.map((site) => DropdownMenuItem<String>(value: site['id'].toString(), child: Text(site['name'] ?? 'Unknown Site'))).toList(),
                        onChanged: _isLoadingSites || _sites.isEmpty ? null : (value) => modalSetState(() => _selectedSiteId = value),
                        validator: (value) => value == null ? 'Please select a site' : null,
                      ),
                      const SizedBox(height: 12),
                      _buildTextFormField(controller: _nameController, label: 'Name', icon: Icons.person, validator: (value) => value!.isEmpty ? 'Enter name' : null),
                      const SizedBox(height: 12),
                      _buildTextFormField(controller: _emailController, label: 'Email', icon: Icons.email, keyboardType: TextInputType.emailAddress, validator: (value) => value!.isEmpty ? 'Enter email' : null),
                      const SizedBox(height: 12),
                      _buildTextFormField(controller: _phoneController, label: 'Phone', icon: Icons.phone, keyboardType: TextInputType.phone, validator: (value) => value!.isEmpty ? 'Enter phone' : null),
                      const SizedBox(height: 12),
                      _buildTextFormField(controller: _notesController, label: 'Notes', icon: Icons.note, maxLines: 3),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            final leadData = {'site_id': _selectedSiteId, 'name': _nameController.text, 'email': _emailController.text, 'phone': _phoneController.text, 'notes': _notesController.text};
                            try {
                              if (lead == null) {
                                await ApiService.createLead(leadData);
                              } else {
                                await ApiService.updateLead(lead['id'].toString(), leadData);
                              }
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lead ${lead == null ? 'added' : 'updated'} successfully')));
                              _refreshLeads();
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48), backgroundColor: const Color(0xFFDF0613), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        child: Text(lead == null ? 'Add Lead' : 'Update Lead'),
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

  Widget _buildTextFormField({ required TextEditingController controller, required String label, required IconData icon, TextInputType? keyboardType, String? Function(String?)? validator, int maxLines = 1}) {
    return TextFormField(controller: controller, decoration: InputDecoration(labelText: label, filled: true, fillColor: Colors.grey[100], border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), prefixIcon: Icon(icon, color: const Color(0xFFDF0613))), keyboardType: keyboardType, validator: validator, maxLines: maxLines);
  }

  // --- NEW AND IMPROVED DELETE FUNCTION ---
  Future<void> _deleteLead(BuildContext context, String? leadId) async {
    if (leadId == null) return;

    // 1. Show a confirmation dialog before deleting
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold)),
          content: const Text('Are you sure you want to delete this lead? This action cannot be undone.', style: TextStyle(fontFamily: 'Nunito')),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel', style: TextStyle(fontFamily: 'Nunito')),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );

    // If the user cancels, do nothing
    if (shouldDelete != true) {
      return;
    }

    // 2. Optimistic UI update
    final int originalIndex = _filteredLeads.indexWhere((lead) => lead['id'].toString() == leadId);
    if (originalIndex == -1) return; // Should not happen

    final leadToDelete = _filteredLeads[originalIndex];
    final originalAllLeadsIndex = _allLeads.indexWhere((lead) => lead['id'].toString() == leadId);


    // Remove from the displayed list immediately
    setState(() {
      _filteredLeads.removeAt(originalIndex);
      if (originalAllLeadsIndex != -1) {
        _allLeads.removeAt(originalAllLeadsIndex);
      }
    });

    try {
      // 3. Make the API call in the background
      await ApiService.deleteLead(leadId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lead deleted successfully')),
        );
      }
    } catch (e) {
      // 4. If the API call fails, restore the lead and show an error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete lead: $e')),
        );
        // Add the lead back to the list in its original position
        setState(() {
          _filteredLeads.insert(originalIndex, leadToDelete);
          if (originalAllLeadsIndex != -1) {
            _allLeads.insert(originalAllLeadsIndex, leadToDelete);
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}