import 'package:flutter/material.dart';
import 'package:untitled1/api_service.dart';
import 'package:untitled1/home_screen.dart';
import 'package:uuid/uuid.dart';

class SitesTab extends StatefulWidget {
  const SitesTab({super.key});

  @override
  _SitesTabState createState() => _SitesTabState();
}

class _SitesTabState extends State<SitesTab> {
  late Future<List<Map<String, dynamic>>> _sitesFuture;
  List<Map<String, dynamic>> _filteredSites = [];
  List<Map<String, dynamic>> _clusters = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoadingClusters = true;

  @override
  void initState() {
    super.initState();
    _sitesFuture = _fetchSites();
    _loadClusters();
    _searchController.addListener(_filterSites);
  }

  Future<List<Map<String, dynamic>>> _fetchSites() async {
    try {
      final sites = await ApiService.getSites();
      _filteredSites = sites; // Initialize filtered list
      return sites;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load sites: $e', style: const TextStyle(fontFamily: 'Nunito', fontSize: 14)),
          ),
        );
      }
      return [];
    }
  }

  Future<void> _loadClusters() async {
    try {
      _clusters = await ApiService.getClusters();
      setState(() {
        _isLoadingClusters = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingClusters = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load clusters: $e', style: const TextStyle(fontFamily: 'Nunito', fontSize: 14)),
          ),
        );
      }
    }
  }

  void _refreshSites() {
    setState(() {
      _sitesFuture = _fetchSites();
    });
  }

  void _filterSites() {
    _sitesFuture.then((sites) {
      final query = _searchController.text.toLowerCase();
      setState(() {
        _filteredSites = sites.where((site) {
          final name = site['name']?.toLowerCase() ?? '';
          final address = site['address']?.toLowerCase() ?? '';
          return name.contains(query) || address.contains(query);
        }).toList();
      });
    });
  }

  bool _isValidUUID(String? uuid) {
    if (uuid == null) return false;
    try {
      Uuid.parse(uuid);
      return true;
    } catch (e) {
      return false;
    }
  }

  void _showSiteActionSheet(BuildContext context, {Map<String, dynamic>? site}) {
    final isEditing = site != null;
    final _nameController = TextEditingController(text: site?['name']);
    final _addressController = TextEditingController(text: site?['address']);
    String? _selectedClusterId = site?['cluster_id'];
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
            initialChildSize: 0.5,
            maxChildSize: 0.7,
            minChildSize: 0.4,
            expand: false,
            builder: (context, scrollController) => SingleChildScrollView(
              controller: scrollController,
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEditing ? 'Edit Site' : 'Add Site',
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Name',
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
                        prefixIcon: const Icon(Icons.label, color: Color(0xFFDF0613)),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.red),
                        ),
                      ),
                      style: const TextStyle(fontFamily: 'Nunito', fontSize: 14),
                      validator: (value) => value!.isEmpty ? 'Enter site name' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        labelText: 'Address',
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
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.red),
                        ),
                      ),
                      style: const TextStyle(fontFamily: 'Nunito', fontSize: 14),
                      validator: (value) => value!.isEmpty ? 'Enter address' : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _isValidUUID(_selectedClusterId) ? _selectedClusterId : null,
                      decoration: InputDecoration(
                        labelText: 'Cluster',
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
                        prefixIcon: const Icon(Icons.group_work, color: Color(0xFFDF0613)),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.red),
                        ),
                      ),
                      hint: _isLoadingClusters
                          ? const Text('Loading clusters...', style: TextStyle(fontFamily: 'Nunito', fontSize: 14))
                          : _clusters.isEmpty
                          ? const Text('No clusters available', style: TextStyle(fontFamily: 'Nunito', fontSize: 14))
                          : const Text('Select a cluster', style: TextStyle(fontFamily: 'Nunito', fontSize: 14)),
                      items: _clusters.map((cluster) {
                        return DropdownMenuItem<String>(
                          value: cluster['id'].toString(),
                          child: Text(
                            cluster['name'] ?? 'Unknown Cluster',
                            style: const TextStyle(fontFamily: 'Nunito', fontSize: 14),
                          ),
                        );
                      }).toList(),
                      onChanged: _isLoadingClusters || _clusters.isEmpty
                          ? null
                          : (value) => modalSetState(() => _selectedClusterId = value),
                      validator: (value) => value == null ? 'Select a cluster' : null,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final siteData = {
                            'name': _nameController.text.trim(),
                            'address': _addressController.text.trim(),
                            'cluster_id': _selectedClusterId,
                          };
                          try {
                            if (isEditing) {
                              await ApiService.updateSite(site!['id'].toString(), siteData);
                            } else {
                              await ApiService.createSite(siteData);
                            }
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Site ${isEditing ? 'updated' : 'added'} successfully',
                                  style: const TextStyle(fontFamily: 'Nunito', fontSize: 14),
                                ),
                              ),
                            );
                            _refreshSites();
                          } catch (e) {
                            String errorMessage = 'Error: $e';
                            if (e.toString().contains('422')) {
                              errorMessage = 'Invalid data provided. Please check the input fields.';
                            } else if (e.toString().contains('500')) {
                              errorMessage = 'Server error. Please try again later or contact support.';
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(errorMessage, style: const TextStyle(fontFamily: 'Nunito', fontSize: 14)),
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
                        isEditing ? 'Update Site' : 'Add Site',
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
          );
        },
      ),
    ).whenComplete(() {
      _nameController.dispose();
      _addressController.dispose();
    });
  }

  Future<void> _deleteSite(BuildContext context, String? siteId) async {
    if (siteId == null || !_isValidUUID(siteId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid site ID', style: TextStyle(fontFamily: 'Nunito', fontSize: 14)),
        ),
      );
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Site', style: TextStyle(fontFamily: 'Nunito', fontSize: 16)),
        content: const Text('Are you sure you want to delete this site?', style: TextStyle(fontFamily: 'Nunito', fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(fontFamily: 'Nunito', fontSize: 14)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(fontFamily: 'Nunito', fontSize: 14, color: Colors.red),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await ApiService.deleteSite(siteId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Site deleted successfully', style: TextStyle(fontFamily: 'Nunito', fontSize: 14)),
          ),
        );
        _refreshSites();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete site: $e', style: const TextStyle(fontFamily: 'Nunito', fontSize: 14)),
          ),
        );
      }
    }
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
          'Sites',
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
                hintText: 'Search by name or address',
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
                    _filterSites();
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
              future: _sitesFuture,
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
                          'Error loading sites',
                          style: TextStyle(fontFamily: 'Nunito', fontSize: 14),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _refreshSites,
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
                final sites = snapshot.data ?? [];
                if (_filteredSites.isEmpty && _searchController.text.isNotEmpty) {
                  return const Center(
                    child: Text(
                      'No matching sites',
                      style: TextStyle(fontFamily: 'Nunito', fontSize: 14),
                    ),
                  );
                }
                if (_filteredSites.isEmpty && sites.isEmpty) {
                  return const Center(
                    child: Text(
                      'No sites available',
                      style: TextStyle(fontFamily: 'Nunito', fontSize: 14),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _filteredSites.length,
                  itemBuilder: (context, index) {
                    final site = _filteredSites[index];
                    final cluster = _clusters.firstWhere(
                          (c) => c['id'] == site['cluster_id'],
                      orElse: () => {'name': 'Unknown Cluster'},
                    );
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
                            site['name']?.isNotEmpty == true ? site['name'][0].toUpperCase() : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'Nunito',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          site['name'] ?? 'Unknown Site',
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        subtitle: Text(
                          'Address: ${site['address'] ?? 'N/A'}\nCluster: ${cluster['name']}',
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
                              onPressed: () => _showSiteActionSheet(context, site: site),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red, size: 24),
                              onPressed: () => _deleteSite(context, site['id'].toString()),
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
            child: Row(
              children: [
                Expanded(
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
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isLoadingClusters || _clusters.isEmpty ? null : () => _showSiteActionSheet(context),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(48, 48),
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Icon(Icons.add, size: 24),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}