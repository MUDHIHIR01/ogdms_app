import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
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
  List<Map<String, dynamic>> _allLeads = [];
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
      if (mounted) {
        setState(() {
          _allLeads = leads;
          _filteredLeads = leads;
        });
      }
      return leads;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to load leads: $e',
              style: const TextStyle(fontFamily: 'Nunito', fontSize: 14),
            ),
          ),
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
        setState(() => _isLoadingSites = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingSites = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to load sites: $e',
              style: const TextStyle(fontFamily: 'Nunito', fontSize: 14),
            ),
          ),
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
        return name.contains(query) ||
            email.contains(query) ||
            phone.contains(query);
      }).toList();
    });
  }

  void _refreshLeads() {
    setState(() {
      _searchController.clear();
      _leadsFuture = _fetchLeads();
    });
  }

  /// Fetches the current device location and handles all permissions.
  /// Returns a map with latitude and longitude, or null on failure.
  Future<Map<String, String>?> _getCurrentLocationAsString() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Use a mounted check to avoid using context after dispose
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Location services are disabled. Please enable them.')),
          );
        }
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location permissions are denied.')),
            );
          }
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Location permissions are permanently denied, we cannot request permissions.')),
          );
        }
        return null;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return {
        'latitude': position.latitude.toString(),
        'longitude': position.longitude.toString(),
      };
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to get location: $e',
              style: const TextStyle(fontFamily: 'Nunito', fontSize: 14),
            ),
          ),
        );
      }
      return null;
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 13.5,
            color: Colors.black54,
          ),
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
    return Scaffold(
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
                prefixIcon: const Icon(Icons.search, color: primaryColor),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: primaryColor),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
              ),
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _leadsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting ||
                    _isLoadingSites) {
                  return const Center(
                    child: CircularProgressIndicator(color: primaryColor),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Failed to load leads: ${snapshot.error}',
                      style: const TextStyle(fontFamily: 'Nunito'),
                    ),
                  );
                }
                if (_filteredLeads.isEmpty) {
                  return Center(
                    child: Text(
                      _searchController.text.isNotEmpty
                          ? 'No matching leads found'
                          : 'No leads available',
                      style: const TextStyle(fontFamily: 'Nunito'),
                    ),
                  );
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
                    final clusterName =
                        site['cluster']?['name'] ?? 'Unknown Cluster';
                    final notes = lead['notes']?.isNotEmpty == true
                        ? lead['notes']
                        : 'No notes provided';
                    final createdAt = _formatDate(lead['created_at']);
                    final latitude = lead['latitude']?.toString() ?? 'N/A';
                    final longitude = lead['longitude']?.toString() ?? 'N/A';

                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              backgroundColor: primaryColor,
                              child: Text(
                                leadName.isNotEmpty
                                    ? leadName[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Nunito',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    leadName,
                                    style: const TextStyle(
                                      fontFamily: 'Nunito',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  _buildInfoRow('Phone', phone),
                                  _buildInfoRow('Email', email),
                                  _buildInfoRow('Cluster', clusterName),
                                  _buildInfoRow('Site', '$siteName ($siteId)'),
                                  _buildInfoRow('Notes', notes),
                                  _buildInfoRow('Created', createdAt),
                                  _buildInfoRow('Latitude', latitude),
                                  _buildInfoRow('Longitude', longitude),
                                ],
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 36,
                                  width: 36,
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: const Icon(
                                      Icons.edit,
                                      color: primaryColor,
                                      size: 22,
                                    ),
                                    onPressed: () =>
                                        _showLeadActionSheet(context, lead),
                                  ),
                                ),
                                SizedBox(
                                  height: 36,
                                  width: 36,
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: const Icon(
                                      Icons.person_add,
                                      color: Colors.green,
                                      size: 22,
                                    ),
                                    onPressed: () => _showCreateCustomerDialog(
                                      context,
                                      lead,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 36,
                                  width: 36,
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                      size: 22,
                                    ),
                                    onPressed: () => _deleteLead(
                                      context,
                                      lead['id']?.toString(),
                                    ),
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
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: () => _showLeadActionSheet(context, null),
        child: const Icon(Icons.add, size: 24, color: Colors.white),
      ),
    );
  }

  /// REFINED: Shows a form to add or edit a lead.
  /// Automatically fetches location for new leads.
  void _showLeadActionSheet(
    BuildContext context,
    Map<String, dynamic>? lead,
  ) {
    final _nameController = TextEditingController(text: lead?['name'] ?? '');
    final _emailController = TextEditingController(text: lead?['email'] ?? '');
    final _phoneController = TextEditingController(text: lead?['phone'] ?? '');
    final _notesController = TextEditingController(text: lead?['notes'] ?? '');
    final _latitudeController =
        TextEditingController(text: lead?['latitude']?.toString() ?? '');
    final _longitudeController =
        TextEditingController(text: lead?['longitude']?.toString() ?? '');
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
          bool _isFetchingLocation = false;
          bool _initialized = false;

          // Fetches location automatically only for new leads.
          Future<void> initializeLocation() async {
            if (lead == null) {
              modalSetState(() => _isFetchingLocation = true);
              final location = await _getCurrentLocationAsString();
              if (mounted && location != null) {
                _latitudeController.text = location['latitude']!;
                _longitudeController.text = location['longitude']!;
              }
              if (mounted) {
                modalSetState(() => _isFetchingLocation = false);
              }
            }
          }

          if (!_initialized) {
            initializeLocation();
            _initialized = true;
          }

          return DraggableScrollableSheet(
            initialChildSize: 0.8,
            maxChildSize: 0.9,
            minChildSize: 0.5,
            expand: false,
            builder: (context, scrollController) => SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                    16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
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
                          prefixIcon: const Icon(
                            Icons.location_on,
                            color: Color(0xFFDF0613),
                          ),
                        ),
                        hint: _isLoadingSites
                            ? const Text('Loading sites...')
                            : const Text('Select a site'),
                        items: _sites
                            .map(
                              (site) => DropdownMenuItem<String>(
                                value: site['id'].toString(),
                                child: Text(site['name'] ?? 'Unknown Site'),
                              ),
                            )
                            .toList(),
                        onChanged: _isLoadingSites || _sites.isEmpty
                            ? null
                            : (value) => modalSetState(
                              () => _selectedSiteId = value,
                            ),
                        validator: (value) =>
                            value == null ? 'Please select a site' : null,
                      ),
                      const SizedBox(height: 12),
                      _buildTextFormField(
                        controller: _nameController,
                        label: 'Name',
                        icon: Icons.person,
                        validator: (value) =>
                            value!.isEmpty ? 'Enter name' : null,
                      ),
                      const SizedBox(height: 12),
                      _buildTextFormField(
                        controller: _emailController,
                        label: 'Email',
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) =>
                            value!.isEmpty ? 'Enter email' : null,
                      ),
                      const SizedBox(height: 12),
                      _buildTextFormField(
                        controller: _phoneController,
                        label: 'Phone',
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        validator: (value) =>
                            value!.isEmpty ? 'Enter phone' : null,
                      ),
                      const SizedBox(height: 12),
                      _buildTextFormField(
                        controller: _notesController,
                        label: 'Notes',
                        icon: Icons.note,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 12),
                      _buildTextFormField(
                        controller: _latitudeController,
                        label: 'Latitude',
                        icon: Icons.map,
                        keyboardType: TextInputType.number,
                        enabled: false, // Read-only to ensure it's auto-filled
                        validator: (value) =>
                            value!.isEmpty ? 'Latitude is required' : null,
                      ),
                      const SizedBox(height: 12),
                      _buildTextFormField(
                        controller: _longitudeController,
                        label: 'Longitude',
                        icon: Icons.map,
                        keyboardType: TextInputType.number,
                        enabled: false, // Read-only to ensure it's auto-filled
                        validator: (value) =>
                            value!.isEmpty ? 'Longitude is required' : null,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _isFetchingLocation
                            ? null // Disable button while fetching location
                            : () async {
                                if (_formKey.currentState!.validate()) {
                                  final leadData = {
                                    'site_id': _selectedSiteId,
                                    'name': _nameController.text,
                                    'email': _emailController.text,
                                    'phone': _phoneController.text,
                                    'notes': _notesController.text,
                                    'latitude': _latitudeController.text,
                                    'longitude': _longitudeController.text,
                                  };
                                  try {
                                    if (lead == null) {
                                      await ApiService.createLead(leadData);
                                    } else {
                                      await ApiService.updateLead(
                                          lead['id'].toString(), leadData);
                                    }
                                    if (mounted) {
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Lead ${lead == null ? 'added' : 'updated'} successfully',
                                            style: const TextStyle(
                                                fontFamily: 'Nunito',
                                                fontSize: 14),
                                          ),
                                        ),
                                      );
                                      _refreshLeads();
                                    }
                                  } catch (e) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Error: $e',
                                            style: const TextStyle(
                                                fontFamily: 'Nunito',
                                                fontSize: 14),
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                          backgroundColor: const Color(0xFFDF0613),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isFetchingLocation
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 3,
                                ),
                              )
                            : Text(
                                lead == null ? 'Add Lead' : 'Update Lead',
                                style: const TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
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
    );
  }

  /// REFINED: Shows a dialog to convert a lead to a customer.
  /// Always fetches a new, current location for the customer record.
  void _showCreateCustomerDialog(
    BuildContext context,
    Map<String, dynamic> lead,
  ) {
    final _nameController = TextEditingController(text: lead['name'] ?? '');
    final _emailController = TextEditingController(text: lead['email'] ?? '');
    final _phoneController = TextEditingController(text: lead['phone'] ?? '');
    final _addressController = TextEditingController();
    final _idTypeController = TextEditingController();
    final _idNumberController = TextEditingController();
    final _tinNumberController = TextEditingController();
    String? _selectedSiteId = lead['site_id']?.toString();
    final _formKey = GlobalKey<FormState>();
    Map<String, String>? _location; // To hold the fetched location

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            bool _isFetchingLocation = false;
            bool _initialized = false;

            // Always fetches a fresh location for the new customer.
            Future<void> fetchLocationForCustomer() async {
              setState(() => _isFetchingLocation = true);
              _location = await _getCurrentLocationAsString();
              if (mounted) {
                setState(() => _isFetchingLocation = false);
              }
            }

            if (!_initialized) {
              fetchLocationForCustomer();
              _initialized = true;
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: const Text(
                'Convert Lead to Customer',
                style:
                    TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
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
                          prefixIcon: const Icon(
                            Icons.location_on,
                            color: Color(0xFFDF0613),
                          ),
                        ),
                        hint: _isLoadingSites
                            ? const Text('Loading sites...')
                            : const Text('Select a site'),
                        items: _sites
                            .map(
                              (site) => DropdownMenuItem<String>(
                                value: site['id'].toString(),
                                child: Text(site['name'] ?? 'Unknown Site'),
                              ),
                            )
                            .toList(),
                        onChanged: _isLoadingSites || _sites.isEmpty
                            ? null
                            : (value) => _selectedSiteId = value,
                        validator: (value) =>
                            value == null ? 'Please select a site' : null,
                      ),
                      const SizedBox(height: 12),
                      _buildTextFormField(
                        controller: _nameController,
                        label: 'Name',
                        icon: Icons.person,
                        validator: (value) =>
                            value!.isEmpty ? 'Enter name' : null,
                      ),
                      const SizedBox(height: 12),
                      _buildTextFormField(
                        controller: _emailController,
                        label: 'Email',
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) =>
                            value!.isEmpty ? 'Enter email' : null,
                      ),
                      const SizedBox(height: 12),
                      _buildTextFormField(
                        controller: _phoneController,
                        label: 'Phone',
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        validator: (value) =>
                            value!.isEmpty ? 'Enter phone' : null,
                      ),
                      const SizedBox(height: 12),
                      _buildTextFormField(
                        controller: _addressController,
                        label: 'Address',
                        icon: Icons.home,
                        validator: (value) =>
                            value!.isEmpty ? 'Enter address' : null,
                      ),
                      const SizedBox(height: 12),
                      _buildTextFormField(
                        controller: _idTypeController,
                        label: 'ID Type',
                        icon: Icons.badge,
                        validator: (value) =>
                            value!.isEmpty ? 'Enter ID type' : null,
                      ),
                      const SizedBox(height: 12),
                      _buildTextFormField(
                        controller: _idNumberController,
                        label: 'ID Number',
                        icon: Icons.perm_identity,
                        validator: (value) =>
                            value!.isEmpty ? 'Enter ID number' : null,
                      ),
                      const SizedBox(height: 12),
                      _buildTextFormField(
                        controller: _tinNumberController,
                        label: 'TIN Number',
                        icon: Icons.account_balance,
                        validator: (value) =>
                            value!.isEmpty ? 'Enter TIN number' : null,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(fontFamily: 'Nunito'),
                  ),
                ),
                ElevatedButton(
                  onPressed: _isFetchingLocation
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            if (_location == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Could not get location. Please ensure location services are on and try again.',
                                    style: TextStyle(
                                        fontFamily: 'Nunito', fontSize: 14),
                                  ),
                                ),
                              );
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
                              'latitude': _location!['latitude'],
                              'longitude': _location!['longitude'],
                            };
                            try {
                              await ApiService.createCustomer(customerData);
                              if (mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Customer created successfully',
                                      style: TextStyle(
                                          fontFamily: 'Nunito', fontSize: 14),
                                    ),
                                  ),
                                );
                                _refreshLeads();
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Error: $e',
                                      style: const TextStyle(
                                          fontFamily: 'Nunito', fontSize: 14),
                                    ),
                                  ),
                                );
                              }
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDF0613),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isFetchingLocation
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : const Text(
                          'Create Customer',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: enabled ? Colors.grey[100] : Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        prefixIcon: Icon(icon, color: const Color(0xFFDF0613)),
      ),
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      enabled: enabled,
      style: const TextStyle(fontFamily: 'Nunito'),
    );
  }

  Future<void> _deleteLead(BuildContext context, String? leadId) async {
    if (leadId == null) return;

    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Confirm Deletion',
            style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Are you sure you want to delete this lead? This action cannot be undone.',
            style: TextStyle(fontFamily: 'Nunito'),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Cancel',
                style: TextStyle(fontFamily: 'Nunito'),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text(
                'Delete',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    final int originalIndex =
        _filteredLeads.indexWhere((lead) => lead['id'].toString() == leadId);
    if (originalIndex == -1) return;

    final leadToDelete = _filteredLeads[originalIndex];
    final originalAllLeadsIndex =
        _allLeads.indexWhere((lead) => lead['id'].toString() == leadId);

    setState(() {
      _filteredLeads.removeAt(originalIndex);
      if (originalAllLeadsIndex != -1) {
        _allLeads.removeAt(originalAllLeadsIndex);
      }
    });

    try {
      await ApiService.deleteLead(leadId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Lead deleted successfully',
              style: TextStyle(fontFamily: 'Nunito', fontSize: 14),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to delete lead: $e',
              style: const TextStyle(fontFamily: 'Nunito', fontSize: 14),
            ),
          ),
        );
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