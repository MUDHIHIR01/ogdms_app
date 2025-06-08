import 'package:flutter/material.dart';
import 'package:untitled1/api_service.dart';
import 'package:untitled1/home_screen.dart';

class ClustersTab extends StatefulWidget {
  const ClustersTab({super.key});

  @override
  _ClustersTabState createState() => _ClustersTabState();
}

class _ClustersTabState extends State<ClustersTab> {
  late Future<List<Map<String, dynamic>>> _clustersFuture;
  List<Map<String, dynamic>> _filteredClusters = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _clustersFuture = _fetchClusters();
    _searchController.addListener(_filterClusters);
  }

  Future<List<Map<String, dynamic>>> _fetchClusters() async {
    try {
      final clusters = await ApiService.getClusters();
      _filteredClusters = clusters; // Initialize filtered list
      return clusters;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load clusters: $e', style: const TextStyle(fontFamily: 'Nunito', fontSize: 14)),
          ),
        );
      }
      return [];
    }
  }

  void _refreshClusters() {
    setState(() {
      _clustersFuture = _fetchClusters();
    });
  }

  void _filterClusters() {
    _clustersFuture.then((clusters) {
      final query = _searchController.text.toLowerCase();
      setState(() {
        _filteredClusters = clusters.where((cluster) {
          final name = cluster['name']?.toLowerCase() ?? '';
          final townName = cluster['town'] != null ? cluster['town']['name']?.toLowerCase() ?? '' : '';
          return name.contains(query) || townName.contains(query);
        }).toList();
      });
    });
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
          'Clusters',
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
                hintText: 'Search by cluster or town name',
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
                    _filterClusters();
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
              future: _clustersFuture,
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
                          'Error loading clusters',
                          style: TextStyle(fontFamily: 'Nunito', fontSize: 14),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _refreshClusters,
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
                final clusters = snapshot.data ?? [];
                if (_filteredClusters.isEmpty && _searchController.text.isNotEmpty) {
                  return const Center(
                    child: Text(
                      'No matching clusters',
                      style: TextStyle(fontFamily: 'Nunito', fontSize: 14),
                    ),
                  );
                }
                if (_filteredClusters.isEmpty && clusters.isEmpty) {
                  return const Center(
                    child: Text(
                      'No clusters available',
                      style: TextStyle(fontFamily: 'Nunito', fontSize: 14),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _filteredClusters.length,
                  itemBuilder: (context, index) {
                    final cluster = _filteredClusters[index];
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
                            cluster['name']?.isNotEmpty == true ? cluster['name'][0].toUpperCase() : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'Nunito',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          cluster['name'] ?? 'Unknown',
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        subtitle: Text(
                          cluster['town'] != null ? cluster['town']['name'] ?? 'No town' : 'No town',
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 14,
                            color: Colors.black54,
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
                  builder: (context) => const HomeScreen(username: 'Guest', role: '',),
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
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}