import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:untitled1/api_service.dart';
import 'package:untitled1/auth_screen.dart';
import 'package:untitled1/photo_upload_screen.dart'; // Import the new photo upload screen
import 'package:untitled1/ticket_form_screen.dart';

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
  bool _isLoading = false; // For showing loading indicators during actions

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
            content: Text('Failed to load tickets: $e', style: const TextStyle(fontFamily: 'Nunito')),
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
          final ticketNo = ticket['ticket_no']?.toLowerCase() ?? '';
          // Add other search fields as needed
          return customerName.contains(query.toLowerCase()) || ticketNo.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  // --- NEW LOGIC: HANDLER FOR STATUS UPDATES ---
  Future<void> _updateTicketStatus(String ticketId, String newStatus, {String? scheduledAt}) async {
    setState(() => _isLoading = true);
    try {
      await ApiService.updateTicketStatus(ticketId, newStatus, scheduledAt: scheduledAt);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ticket status updated to ${newStatus.capitalize()}'),
            backgroundColor: Colors.green,
          ),
        );
      }
      _refreshTickets(); // Refresh the list to show the new status
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- NEW LOGIC: HANDLER FOR SCHEDULING ---
  Future<void> _handleSchedule(BuildContext context, String ticketId) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return; // User cancelled date picker

    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(DateTime.now()),
    );
    if (time == null || !mounted) return; // User cancelled time picker

    final fullDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    // Format to 'Y-m-d H:i:s' as required by the API
    final String formattedTimestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(fullDateTime);
    
    await _updateTicketStatus(ticketId, 'scheduled', scheduledAt: formattedTimestamp);
  }

  // --- NEW LOGIC: HANDLER FOR NAVIGATING TO PHOTO UPLOAD ---
  void _navigateToPhotoUpload(String ticketId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PhotoUploadScreen(ticketId: ticketId)),
    ).then((result) {
      // If the upload screen returns 'true', it means the upload was successful
      if (result == true) {
        _refreshTickets(); // Refresh to reflect any related changes
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFDF0613);
    const backgroundColor = Colors.white;
    // Only 'dse' can create new tickets.
    final bool canCreate = widget.role == 'dse';

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Tickets', style: TextStyle(color: Colors.white, fontSize: 18, fontFamily: 'Nunito', fontWeight: FontWeight.bold)),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: AbsorbPointer(
        absorbing: _isLoading,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                // ... Search field setup ...
              ),
            ),
            if (_isLoading)
              const LinearProgressIndicator(
                backgroundColor: Colors.white,
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _fetchTickets,
                color: primaryColor,
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _ticketsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting && !_isLoading) {
                      return const Center(child: CircularProgressIndicator(color: primaryColor));
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Failed to load tickets: ${snapshot.error}'));
                    }
                    final tickets = snapshot.data ?? [];
                    if (tickets.isEmpty) return const Center(child: Text('No tickets available'));

                    final displayTickets = _searchQuery.isEmpty ? tickets : _filteredTickets;
                    if (displayTickets.isEmpty) return const Center(child: Text('No matching tickets'));

                    return ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: displayTickets.length,
                      itemBuilder: (context, index) {
                        final ticket = displayTickets[index];
                        // Dim the card if loading to provide visual feedback at a glance
                        return Opacity(
                          opacity: _isLoading ? 0.5 : 1.0,
                          child: _buildTicketCard(context, ticket),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: canCreate
          ? FloatingActionButton(
              backgroundColor: primaryColor,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TicketFormScreen()),
              ).then((result) {
                if (result == true) _refreshTickets();
              }),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildTicketCard(BuildContext context, Map<String, dynamic> ticket) {
    // Extract ticket details
    final ticketId = ticket['id']?.toString() ?? '';
    final ticketNo = ticket['ticket_no'] ?? 'N/A';
    final customerName = ticket['customer']?['name'] ?? 'Unknown';
    final serviceType = ticket['service_type']?['name'] ?? 'Unknown';
    final status = ticket['status']?.toString().toLowerCase() ?? 'na'; // Use lowercase for logic
    final statusDisplay = status.capitalize();
    final notes = ticket['notes'] ?? 'No notes';
    final scheduledAt = ticket['scheduled_at'] != null ? DateFormat('MMM dd, yyyy HH:mm').format(DateTime.parse(ticket['scheduled_at'])) : 'Not scheduled';
    final createdAt = ticket['created_at'] != null ? DateFormat('MMM dd, yyyy HH:mm').format(DateTime.parse(ticket['created_at'])) : 'N/A';

    // 'dse' can edit ticket details via form, 'installer' uses workflow buttons.
    final bool canEdit = widget.role == 'dse';

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFDF0613),
          radius: 20,
          child: Text(customerName.isNotEmpty ? customerName[0].toUpperCase() : '?', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        title: Text('$ticketNo - $customerName', style: const TextStyle(fontFamily: 'Nunito', fontSize: 16, fontWeight: FontWeight.w600)),
        subtitle: Text('Service: $serviceType | Status: $statusDisplay', style: const TextStyle(fontFamily: 'Nunito', fontSize: 14)),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Scheduled', scheduledAt),
                _buildDetailRow('Created', createdAt),
                _buildDetailRow('Notes', notes, maxLines: 3),
                const SizedBox(height: 16),

                // --- NEW: RENDER INSTALLER ACTION BUTTONS ---
                if (widget.role == 'installer')
                  ..._buildInstallerActions(context, ticketId, status),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // --- Edit button is only for 'dse' role ---
                    if (canEdit)
                      IconButton(
                        icon: const Icon(Icons.edit, color: Color(0xFFDF0613)),
                        tooltip: 'Edit Ticket Details',
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => TicketFormScreen(ticket: ticket)),
                        ).then((result) {
                          if (result == true) _refreshTickets();
                        }),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- NEW LOGIC: HELPER TO BUILD INSTALLER ACTION BUTTONS ---
  List<Widget> _buildInstallerActions(BuildContext context, String ticketId, String status) {
    const primaryColor = Color(0xFFDF0613);
    final buttonStyle = ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        textStyle: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold),
    );

    List<Widget> actions;

    switch (status) {
      case 'pending':
        actions = [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.check_circle, size: 18),
                label: const Text('Confirm'),
                style: buttonStyle,
                onPressed: () => _updateTicketStatus(ticketId, 'confirmed'),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.cancel, size: 18),
                label: const Text('Cancel'),
                style: buttonStyle.copyWith(backgroundColor: MaterialStateProperty.all(Colors.grey[700])),
                onPressed: () => _updateTicketStatus(ticketId, 'cancelled'),
              ),
            ],
          ),
        ];
        break;
      case 'confirmed':
        actions = [
          Center(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.calendar_today, size: 18),
              label: const Text('Schedule Installation'),
              style: buttonStyle,
              onPressed: () => _handleSchedule(context, ticketId),
            ),
          )
        ];
        break;
      case 'scheduled':
        actions = [
          Center(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.person_pin_circle, size: 18),
              label: const Text('Mark as Attended'),
              style: buttonStyle,
              onPressed: () => _updateTicketStatus(ticketId, 'attended'),
            ),
          )
        ];
        break;
      case 'attended':
        actions = [
          Center(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.build_circle, size: 18),
              label: const Text('Mark as Installed'),
              style: buttonStyle,
              onPressed: () => _updateTicketStatus(ticketId, 'installed'),
            ),
          )
        ];
        break;
      case 'installed':
        actions = [
          Center(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.camera_alt, size: 18),
              label: const Text('Upload Installation Photos'),
              style: buttonStyle,
              onPressed: () => _navigateToPhotoUpload(ticketId),
            ),
          )
        ];
        break;
      default:
        actions = []; // No actions for 'postponed', 'cancelled', etc.
    }
    
    // Add a divider if any actions are present to separate them from the edit button row
    if (actions.isNotEmpty) {
      actions.add(const Divider(height: 32, thickness: 1, indent: 20, endIndent: 20));
    }
    return actions;
  }

  Widget _buildDetailRow(String label, String value, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text('$label:', style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w600)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontFamily: 'Nunito', color: Colors.black54), maxLines: maxLines, overflow: TextOverflow.ellipsis),
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