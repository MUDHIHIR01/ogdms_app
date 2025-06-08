import 'package:flutter/material.dart';
import 'package:untitled1/api_service.dart';
import 'package:untitled1/home_screen.dart';

class ServiceTypesTab extends StatefulWidget {
  const ServiceTypesTab({super.key});

  @override
  _ServiceTypesTabState createState() => _ServiceTypesTabState();
}

class _ServiceTypesTabState extends State<ServiceTypesTab> {
  late Future<List<Map<String, dynamic>>> _serviceTypesFuture;
  String _searchQuery = '';
  List<Map<String, dynamic>> _filteredServiceTypes = [];

  @override
  void initState() {
    super.initState();
    _serviceTypesFuture = _fetchServiceTypes();
  }

  Future<List<Map<String, dynamic>>> _fetchServiceTypes() async {
    try {
      final serviceTypes = await ApiService.getServiceTypes();
      _filteredServiceTypes = serviceTypes; // Initialize filtered list
      return serviceTypes;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load service types: $e',
                style: const TextStyle(fontFamily: 'Nunito', fontSize: 14)),
          ),
        );
      }
      return [];
    }
  }

  void _filterServiceTypes(String query, List<Map<String, dynamic>> serviceTypes) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredServiceTypes = serviceTypes;
      } else {
        _filteredServiceTypes = serviceTypes
            .where((serviceType) => (serviceType['name'] ?? '')
            .toLowerCase()
            .contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFDF0613);
    const backgroundColor = Colors.white;
    const cardColor = Colors.white; // Explicit white background for cards

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Service Types',
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
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search service types...',
                hintStyle: TextStyle(
                  color: Colors.grey[600],
                  fontFamily: 'Nunito',
                  fontSize: 14,
                ),
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
                  borderSide: BorderSide(color: primaryColor, width: 1),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey[600],
                  size: 24,
                ),
                contentPadding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
              style: const TextStyle(
                color: Colors.black87,
                fontFamily: 'Nunito',
                fontSize: 14,
              ),
              onChanged: (value) {
                _serviceTypesFuture.then(
                        (serviceTypes) => _filterServiceTypes(value, serviceTypes));
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _serviceTypesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      'Error loading service types',
                      style: TextStyle(fontFamily: 'Nunito', fontSize: 14),
                    ),
                  );
                }
                final serviceTypes = snapshot.data ?? [];
                if (serviceTypes.isEmpty) {
                  return const Center(
                    child: Text(
                      'No service types available',
                      style: TextStyle(fontFamily: 'Nunito', fontSize: 14),
                    ),
                  );
                }
                final displayServiceTypes =
                _searchQuery.isEmpty ? serviceTypes : _filteredServiceTypes;
                if (displayServiceTypes.isEmpty && _searchQuery.isNotEmpty) {
                  return const Center(
                    child: Text(
                      'No matching service types',
                      style: TextStyle(fontFamily: 'Nunito', fontSize: 14),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: displayServiceTypes.length,
                  itemBuilder: (context, index) {
                    final serviceType = displayServiceTypes[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: cardColor, // Explicitly set white background
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        leading: const Icon(
                          Icons.build,
                          color: primaryColor,
                          size: 24,
                        ),
                        title: Text(
                          serviceType['name'] ?? 'Unknown',
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
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
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Back to Home',
                style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 14,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}