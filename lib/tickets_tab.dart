import 'package:flutter/material.dart';
import 'package:untitled1/api_service.dart';
import 'package:untitled1/home_screen.dart';
import 'package:untitled1/ticket_form_screen.dart';

class TicketsTab extends StatefulWidget {
  const TicketsTab({super.key});

  @override
  _TicketsTabState createState() => _TicketsTabState();
}

class _TicketsTabState extends State<TicketsTab> {
  late Future<List<Map<String, dynamic>>> _ticketsFuture;
  String _searchQuery = '';
  List<Map<String, dynamic>> _filteredTickets = [];

  @override
  void initState() {
    super.initState();
    _ticketsFuture = _fetchTickets();
  }

  Future<List<Map<String, dynamic>>> _fetchTickets() async {
    try {
      final tickets = await ApiService.getTickets();
      _filteredTickets = tickets; // Initialize filtered list
      return tickets;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load tickets: $e',
                style: const TextStyle(fontFamily: 'Nunito', fontSize: 14)),
          ),
        );
      }
      return [];
    }
  }

  void _refreshTickets() {
    setState(() {
      _ticketsFuture = _fetchTickets();
    });
  }

  void _filterTickets(String query, List<Map<String, dynamic>> tickets) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredTickets = tickets;
      } else {
        _filteredTickets = tickets.where((ticket) {
          final customerName = ticket['customer']?['name']?.toLowerCase() ?? '';
          final siteName = ticket['customer']?['site']?['name']?.toLowerCase() ?? '';
          final serviceType = ticket['service_type']?['name']?.toLowerCase() ?? '';
          final status = ticket['status']?.toLowerCase() ?? '';
          final queryLower = query.toLowerCase();
          return customerName.contains(queryLower) ||
              siteName.contains(queryLower) ||
              serviceType.contains(queryLower) ||
              status.contains(queryLower);
        }).toList();
      }
    });
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
          'Tickets',
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
                hintText: 'Search tickets by customer, site, service, or status...',
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
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
              style: const TextStyle(
                color: Colors.black87,
                fontFamily: 'Nunito',
                fontSize: 14,
              ),
              onChanged: (value) {
                _ticketsFuture.then((tickets) => _filterTickets(value, tickets));
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _ticketsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: primaryColor));
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Failed to load tickets: ${snapshot.error}',
                          style: const TextStyle(fontFamily: 'Nunito', fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _refreshTickets,
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
                final tickets = snapshot.data ?? [];
                if (tickets.isEmpty) {
                  return const Center(
                    child: Text(
                      'No tickets available',
                      style: TextStyle(fontFamily: 'Nunito', fontSize: 14),
                    ),
                  );
                }
                final displayTickets = _searchQuery.isEmpty ? tickets : _filteredTickets;
                if (displayTickets.isEmpty && _searchQuery.isNotEmpty) {
                  return const Center(
                    child: Text(
                      'No matching tickets',
                      style: TextStyle(fontFamily: 'Nunito', fontSize: 14),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: displayTickets.length,
                  itemBuilder: (context, index) {
                    final ticket = displayTickets[index];
                    return _buildTicketCard(context, ticket);
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
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TicketFormScreen()),
        ).then((_) => _refreshTickets()),
        child: const Icon(Icons.add, size: 24, color: Colors.white),
      ),
    );
  }

  Widget _buildTicketCard(BuildContext context, Map<String, dynamic> ticket) {
    final customerName = ticket['customer']?['name'] ?? 'Unknown';
    final siteName = ticket['customer']?['site']?['name'] ?? 'Unknown';
    final serviceType = ticket['service_type']?['name'] ?? 'Unknown';
    final status = ticket['status']?.toUpperCase() ?? 'Unknown';

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white, // Explicit white background
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFDF0613),
          radius: 20,
          child: Text(
            customerName.isNotEmpty ? customerName[0].toUpperCase() : '?',
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Nunito',
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          customerName,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Site: $siteName',
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            Text(
              'Service: $serviceType',
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            Text(
              'Status: $status',
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Color(0xFFDF0613), size: 24),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TicketFormScreen(ticket: ticket)),
              ).then((_) => _refreshTickets()),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red, size: 24),
              onPressed: () => _deleteTicket(context, ticket['id']),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteTicket(BuildContext context, String? ticketId) async {
    if (ticketId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid ticket ID', style: TextStyle(fontFamily: 'Nunito', fontSize: 14)),
        ),
      );
      return;
    }
    try {
      await ApiService.deleteTicket(ticketId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ticket deleted successfully', style: TextStyle(fontFamily: 'Nunito', fontSize: 14)),
        ),
      );
      _refreshTickets();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete ticket: $e', style: const TextStyle(fontFamily: 'Nunito', fontSize: 14)),
        ),
      );
    }
  }
}