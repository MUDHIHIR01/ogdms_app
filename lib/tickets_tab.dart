import 'package:flutter/material.dart';
import 'package:untitled1/api_service.dart';
import 'package:untitled1/ticket_form_screen.dart';
import 'package:untitled1/auth_screen.dart';
import 'package:intl/intl.dart'; // For formatting dates

class TicketsTab extends StatefulWidget {
  final String role;
  const TicketsTab({super.key, required this.role});

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
      // Sort tickets by creation date, newest first
      tickets.sort((a, b) {
        final dateA = a['created_at'] != null ? DateTime.parse(a['created_at']) : DateTime(1970);
        final dateB = b['created_at'] != null ? DateTime.parse(b['created_at']) : DateTime(1970);
        return dateB.compareTo(dateA);
      });
      if (mounted) {
        setState(() {
          _filteredTickets = tickets; // Initialize filtered list
        });
      }
      return tickets;
    } catch (e) {
      if (mounted) {
        if (e.toString().contains('Unauthenticated')) {
          // Redirect to AuthScreen on unauthenticated error
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ApiService.logout(); // Clear token
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const AuthScreen()),
              (route) => false,
            );
          });
          return [];
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load tickets: $e', style: const TextStyle(fontFamily: 'Nunito', fontSize: 14)),
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
          final notes = ticket['notes']?.toLowerCase() ?? '';
          final phone = ticket['customer']?['phone']?.toLowerCase() ?? '';
          final email = ticket['customer']?['email']?.toLowerCase() ?? '';
          final ticketNo = ticket['ticket_no']?.toLowerCase() ?? '';
          final queryLower = query.toLowerCase();
          return customerName.contains(queryLower) ||
              siteName.contains(queryLower) ||
              serviceType.contains(queryLower) ||
              notes.contains(queryLower) ||
              phone.contains(queryLower) ||
              email.contains(queryLower) ||
              ticketNo.contains(queryLower);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFDF0613);
    const backgroundColor = Colors.white;
    // --- ROLE LOGIC ---
    // Only 'dse' can create new tickets.
    final bool canCreate = widget.role == 'dse';

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
                hintText: 'Search by ticket no, customer, site, service, notes, phone, or email...',
                hintStyle: TextStyle(color: Colors.grey[600], fontFamily: 'Nunito', fontSize: 14),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryColor, width: 1)),
                prefixIcon: Icon(Icons.search, color: Colors.grey[600], size: 24),
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
              style: const TextStyle(color: Colors.black87, fontFamily: 'Nunito', fontSize: 14),
              onChanged: (value) {
                _ticketsFuture.then((tickets) => _filterTickets(value, tickets));
              },
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchTickets,
              color: primaryColor,
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
                            child: const Text('Retry', style: TextStyle(fontFamily: 'Nunito', fontSize: 14)),
                          ),
                        ],
                      ),
                    );
                  }
                  final tickets = snapshot.data ?? [];
                  if (tickets.isEmpty) {
                    return const Center(
                      child: Text('No tickets available', style: TextStyle(fontFamily: 'Nunito', fontSize: 14)),
                    );
                  }
                  final displayTickets = _searchQuery.isEmpty ? tickets : _filteredTickets;
                  if (displayTickets.isEmpty && _searchQuery.isNotEmpty) {
                    return const Center(
                      child: Text('No matching tickets', style: TextStyle(fontFamily: 'Nunito', fontSize: 14)),
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
          ),
        ],
      ),
      floatingActionButton: canCreate
          ? FloatingActionButton(
              backgroundColor: primaryColor,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TicketFormScreen()),
                // Refresh the list after a new ticket might have been created.
              ).then((result) {
                if (result == true) {
                  _refreshTickets();
                }
              }),
              child: const Icon(Icons.add, size: 24, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildTicketCard(BuildContext context, Map<String, dynamic> ticket) {
    // Extract ticket details
    final ticketNo = ticket['ticket_no'] ?? 'N/A';
    final customerName = ticket['customer']?['name'] ?? 'Unknown';
    final customerPhone = ticket['customer']?['phone'] ?? 'N/A';
    final customerEmail = ticket['customer']?['email'] ?? 'N/A';
    final customerAddress = ticket['customer']?['address'] ?? 'N/A';
    final siteName = ticket['customer']?['site']?['name'] ?? 'Unknown';
    final siteId = ticket['customer']?['site']?['site_id'] ?? 'N/A';
    final clusterName = ticket['customer']?['site']?['cluster']?['name'] ?? 'N/A';
    final townName = ticket['customer']?['site']?['cluster']?['town']?['name'] ?? 'N/A';
    final serviceType = ticket['service_type']?['name'] ?? 'Unknown';
    final status = ticket['status']?.toString().capitalize() ?? 'N/A';
    final notes = ticket['notes'] ?? 'No notes';
    final scheduledAt = ticket['scheduled_at'] != null
        ? DateFormat('MMM dd, yyyy HH:mm').format(DateTime.parse(ticket['scheduled_at']))
        : 'Not scheduled';
    final createdAt = ticket['created_at'] != null
        ? DateFormat('MMM dd, yyyy HH:mm').format(DateTime.parse(ticket['created_at']))
        : 'N/A';

    // --- NEW: ROLE-BASED EDIT LOGIC ---
    // 'dse' and 'installer' can edit existing tickets.
    final bool canEdit = widget.role == 'dse' || widget.role == 'installer';

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: ExpansionTile(
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
          '$ticketNo - $customerName',
          style: const TextStyle(fontFamily: 'Nunito', fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        subtitle: Text(
          'Service: $serviceType | Status: $status',
          style: const TextStyle(fontFamily: 'Nunito', fontSize: 14, color: Colors.black54),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Ticket No', ticketNo),
                _buildDetailRow('Phone', customerPhone),
                _buildDetailRow('Email', customerEmail),
                _buildDetailRow('Address', customerAddress),
                _buildDetailRow('Site', siteName),
                _buildDetailRow('Site ID', siteId),
                _buildDetailRow('Cluster', clusterName),
                _buildDetailRow('Town', townName),
                _buildDetailRow('Service Type', serviceType),
                _buildDetailRow('Scheduled', scheduledAt),
                _buildDetailRow('Created', createdAt),
                _buildDetailRow('Notes', notes, maxLines: 3),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // --- NEW: Conditionally render the Edit button based on role ---
                    if (canEdit)
                      IconButton(
                        icon: const Icon(Icons.edit, color: Color(0xFFDF0613), size: 24),
                        tooltip: 'Edit Ticket',
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => TicketFormScreen(ticket: ticket)),
                          // Refresh the list after the ticket might have been updated.
                        ).then((result) {
                          if (result == true) {
                            _refreshTickets();
                          }
                        }),
                      ),
                    // No delete button is shown for any role, as requested.
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontFamily: 'Nunito', fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontFamily: 'Nunito', fontSize: 14, color: Colors.black54),
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }
}