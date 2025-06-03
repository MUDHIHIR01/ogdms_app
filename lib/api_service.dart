import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static String get baseUrl {
    final url = dotenv.env['API_BASE_URL'];
    if (url == null || url.isEmpty) {
      throw Exception('API_BASE_URL is not set in .env file');
    }
    return url;
  }

  static String? _token;

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _token = data['token'];
      return data;
    }
    throw Exception('Login failed: ${response.statusCode}');
  }

  static Future<void> forgotPassword(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/forgot_password'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email}),
    );
    if (response.statusCode != 200) {
      throw Exception('Forgot password failed: ${response.statusCode}');
    }
  }

  static Future<void> resetPassword(String email, String password, String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/reset_password'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password, 'token': token}),
    );
    if (response.statusCode != 200) {
      throw Exception('Reset password failed: ${response.statusCode}');
    }
  }

  static Future<void> logout() async {
    if (_token == null) throw Exception('Not authenticated');
    final response = await http.post(
      Uri.parse('$baseUrl/auth/logout'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
    );
    if (response.statusCode == 200) {
      _token = null;
    } else {
      throw Exception('Logout failed: ${response.statusCode}');
    }
  }

  static Future<List<Map<String, dynamic>>> getSites() async {
    if (_token == null) throw Exception('Not authenticated');
    final response = await http.get(
      Uri.parse('$baseUrl/sites'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
    );
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    }
    throw Exception('Failed to load sites: ${response.statusCode}');
  }

  static Future<List<Map<String, dynamic>>> getClusters() async {
    if (_token == null) throw Exception('Not authenticated');
    final response = await http.get(
      Uri.parse('$baseUrl/clusters'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
    );
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    }
    throw Exception('Failed to load clusters: ${response.statusCode}');
  }

  static Future<List<Map<String, dynamic>>> getDeviceTypes() async {
    if (_token == null) throw Exception('Not authenticated');
    final response = await http.get(
      Uri.parse('$baseUrl/device_types'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
    );
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    }
    throw Exception('Failed to load device types: ${response.statusCode}');
  }

  static Future<List<Map<String, dynamic>>> getServiceTypes() async {
    if (_token == null) throw Exception('Not authenticated');
    final response = await http.get(
      Uri.parse('$baseUrl/service_types'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
    );
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    }
    throw Exception('Failed to load service types: ${response.statusCode}');
  }

  static Future<List<Map<String, dynamic>>> getLeads() async {
    if (_token == null) throw Exception('Not authenticated');
    final response = await http.get(
      Uri.parse('$baseUrl/leads'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
    );
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    }
    throw Exception('Failed to load leads: ${response.statusCode}');
  }

  static Future<void> createLead(Map<String, dynamic> leadData) async {
    if (_token == null) throw Exception('Not authenticated');
    final response = await http.post(
      Uri.parse('$baseUrl/leads'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
      body: json.encode(leadData),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to create lead: ${response.statusCode}');
    }
  }

  static Future<void> updateLead(String id, Map<String, dynamic> leadData) async {
    if (_token == null) throw Exception('Not authenticated');
    final response = await http.put(
      Uri.parse('$baseUrl/leads/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
      body: json.encode(leadData),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update lead: ${response.statusCode}');
    }
  }

  static Future<void> deleteLead(String id) async {
    if (_token == null) throw Exception('Not authenticated');
    final response = await http.delete(
      Uri.parse('$baseUrl/leads/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete lead: ${response.statusCode}');
    }
  }

  static Future<List<Map<String, dynamic>>> getCustomers() async {
    if (_token == null) throw Exception('Not authenticated');
    final response = await http.get(
      Uri.parse('$baseUrl/customers'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
    );
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    }
    throw Exception('Failed to load customers: ${response.statusCode}');
  }

  static Future<Map<String, dynamic>> createCustomer(Map<String, dynamic> customerData) async {
    if (_token == null) throw Exception('Not authenticated');
    final response = await http.post(
      Uri.parse('$baseUrl/customers'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
      body: json.encode(customerData),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to create customer: ${response.statusCode}');
    }
    return json.decode(response.body);
  }

  static Future<void> updateCustomer(String id, Map<String, dynamic> customerData) async {
    if (_token == null) throw Exception('Not authenticated');
    final response = await http.put(
      Uri.parse('$baseUrl/customers/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
      body: json.encode(customerData),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update customer: ${response.statusCode}');
    }
  }

  static Future<void> deleteCustomer(String id) async {
    if (_token == null) throw Exception('Not authenticated');
    final response = await http.delete(
      Uri.parse('$baseUrl/customers/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete customer: ${response.statusCode}');
    }
  }

  static Future<List<Map<String, dynamic>>> getTickets() async {
    if (_token == null) throw Exception('Not authenticated');
    final response = await http.get(
      Uri.parse('$baseUrl/tickets'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
    );
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    }
    throw Exception('Failed to load tickets: ${response.statusCode}');
  }

  static Future<Map<String, dynamic>> createTicket(Map<String, dynamic> ticketData) async {
    if (_token == null) throw Exception('Not authenticated');
    final response = await http.post(
      Uri.parse('$baseUrl/tickets'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
      body: json.encode(ticketData),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to create ticket: ${response.statusCode}');
    }
    return json.decode(response.body);
  }

  static Future<void> updateTicket(String id, Map<String, dynamic> ticketData) async {
    if (_token == null) throw Exception('Not authenticated');
    final response = await http.put(
      Uri.parse('$baseUrl/tickets/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
      body: json.encode(ticketData),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update ticket: ${response.statusCode}');
    }
  }

  static Future<void> deleteTicket(String id) async {
    if (_token == null) throw Exception('Not authenticated');
    final response = await http.delete(
      Uri.parse('$baseUrl/tickets/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete ticket: ${response.statusCode}');
    }
  }

  static Future<List<Map<String, dynamic>>> getNotifications() async {
    if (_token == null) throw Exception('Not authenticated');
    final response = await http.get(
      Uri.parse('$baseUrl/notifications'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
    );
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    }
    throw Exception('Failed to load notifications: ${response.statusCode}');
  }
}