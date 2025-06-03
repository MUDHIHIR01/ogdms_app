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

  @override
  void initState() {
    super.initState();
    _ticketsFuture = ApiService.getTickets();
  }

  void _refreshTickets() {
    setState(() {
      _ticketsFuture = ApiService.getTickets();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Tickets', style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Nunito')),
        backgroundColor: const Color(0xFFDF0613),
        iconTheme: const IconThemeData(color: Colors.white), // Set back arrow color to white
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _ticketsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading tickets', style: TextStyle(fontFamily: 'Nunito', fontSize: 14)));
                }
                final tickets = snapshot.data ?? [];
                if (tickets.isEmpty) {
                  return const Center(
                    child: Text('No tickets', style: TextStyle(fontFamily: 'Nunito', fontSize: 14)),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: tickets.length,
                  itemBuilder: (context, index) {
                    final ticket = tickets[index];
                    return Card(
                      elevation: 1,
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFFDF0613),
                          child: Text(
                            ticket['title']?.isNotEmpty == true ? ticket['title'][0] : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'Nunito',
                              fontSize: 14,
                            ),
                          ),
                        ),
                        title: Text(
                          ticket['title'] ?? 'Unknown',
                          style: const TextStyle(fontFamily: 'Nunito', fontSize: 14),
                        ),
                        subtitle: Text(
                          'Status: ${ticket['status'] ?? 'Unknown'} | Type: ${ticket['type'] ?? 'Unknown'}',
                          style: const TextStyle(fontFamily: 'Nunito', fontSize: 12),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Color(0xFFDF0613), size: 20),
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TicketFormScreen(ticket: ticket),
                                ),
                              ).then((_) => _refreshTickets()),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                              onPressed: () async {
                                try {
                                  await ApiService.deleteTicket(ticket['id']);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Ticket deleted', style: TextStyle(fontSize: 14))),
                                  );
                                  _refreshTickets();
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error: $e', style: TextStyle(fontSize: 14))),
                                  );
                                }
                              },
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
                MaterialPageRoute(
                  builder: (context) => const HomeScreen(username: 'Guest'),
                ),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                backgroundColor: Colors.grey[300],
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Back to Home', style: TextStyle(fontSize: 14)),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFDF0613),
        child: const Icon(Icons.add, size: 20, color: Colors.white),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const TicketFormScreen(),
          ),
        ).then((_) => _refreshTickets()),
      ),
    );
  }
}