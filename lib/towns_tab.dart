import 'package:flutter/material.dart';
import 'package:untitled1/api_service.dart';
import 'package:untitled1/home_screen.dart';

class TownsTab extends StatefulWidget {
  const TownsTab({super.key});

  @override
  _TownsTabState createState() => _TownsTabState();
}

class _TownsTabState extends State<TownsTab> {
  late Future<List<Map<String, dynamic>>> _townsFuture;
  List<Map<String, dynamic>> _filteredTowns = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _townsFuture = _fetchTowns();
    _searchController.addListener(_filterTowns);
  }

  Future<List<Map<String, dynamic>>> _fetchTowns() async {
    try {
      final towns = await ApiService.getTowns();
      _filteredTowns = towns; // Initialize filtered list
      return towns;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load towns: $e', style: const TextStyle(fontFamily: 'Nunito', fontSize: 14)),
          ),
        );
      }
      return [];
    }
  }

  void _refreshTowns() {
    setState(() {
      _townsFuture = _fetchTowns();
    });
  }

  void _filterTowns() {
    _townsFuture.then((towns) {
      final query = _searchController.text.toLowerCase();
      setState(() {
        _filteredTowns = towns.where((town) {
          final name = town['name']?.toLowerCase() ?? '';
          return name.contains(query);
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
          'Towns',
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
                hintText: 'Search by town name',
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
                    _filterTowns();
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
              future: _townsFuture,
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
                          'Error loading towns',
                          style: TextStyle(fontFamily: 'Nunito', fontSize: 14),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _refreshTowns,
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
                final towns = snapshot.data ?? [];
                if (_filteredTowns.isEmpty && _searchController.text.isNotEmpty) {
                  return const Center(
                    child: Text(
                      'No matching towns',
                      style: TextStyle(fontFamily: 'Nunito', fontSize: 14),
                    ),
                  );
                }
                if (_filteredTowns.isEmpty && towns.isEmpty) {
                  return const Center(
                    child: Text(
                      'No towns available',
                      style: TextStyle(fontFamily: 'Nunito', fontSize: 14),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _filteredTowns.length,
                  itemBuilder: (context, index) {
                    final town = _filteredTowns[index];
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
                            town['name']?.isNotEmpty == true ? town['name'][0].toUpperCase() : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'Nunito',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          town['name'] ?? 'Unknown',
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