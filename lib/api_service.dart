
class ApiService {
static const String baseUrl = 'https://api.example.com'; // Placeholder for future API

// Mock data placeholder
static Future<List<Map<String, String>>> getTickets() async {
await Future.delayed(const Duration(seconds: 1));
return [
{'title': 'Issue #1', 'description': 'App crash'},
{'title': 'Issue #2', 'description': 'Slow loading'},
];
}

static Future<List<Map<String, String>>> getCustomers() async {
await Future.delayed(const Duration(seconds: 1));
return [
{'name': 'Alice', 'email': 'alice@example.com', 'phone': '1234567890'},
{'name': 'Bob', 'email': 'bob@example.com', 'phone': '0987654321'},
];
}

static Future<List<Map<String, String>>> getNotifications() async {
await Future.delayed(const Duration(seconds: 1));
return [
{'message': 'New ticket assigned', 'date': '2025-06-02'},
{'message': 'Profile updated', 'date': '2025-06-01'},
];
}
}