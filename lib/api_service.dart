import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class ApiService {
  static const String baseUrl = 'https://ogdms.extrock.com/api';
  static String? _token;

  static Map<String, String> _getHeaders() => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  /// Logs in a user and stores the access token
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http
          .post(
        Uri.parse('$baseUrl/auth/login'),
        headers: _getHeaders(),
        body: json.encode({'email': email, 'password': password}),
      )
          .timeout(const Duration(seconds: 10));

      print('Login Response status: ${response.statusCode}');
      print('Login Response headers: ${response.headers}');
      print('Login Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map<String, dynamic> &&
            data['access_token'] is String &&
            data['token_type'] == 'Bearer' &&
            data['user'] != null) {
          _token = data['access_token'];
          return {
            'access_token': data['access_token'],
            'token_type': data['token_type'],
            'user': data['user'],
            'roles': data['roles'] ?? [],
          };
        }
        throw 'Invalid response format';
      } else if (response.statusCode == 403) {
        throw 'Email not verified.';
      } else if (response.statusCode == 422) {
        throw 'The provided credentials are incorrect.';
      } else if (response.statusCode == 301 || response.statusCode == 302) {
        throw 'Unexpected redirect to ${response.headers['location']}';
      } else {
        throw 'Login failed: ${response.statusCode}';
      }
    } on SocketException {
      throw 'No internet connection';
    } on TimeoutException {
      throw 'Request timed out';
    } on FormatException {
      throw 'Invalid JSON response';
    } catch (e) {
      throw 'An unexpected error occurred: $e';
    }
  }

  /// Sends a password reset token request to the provided email
  static Future<String> forgotPassword(String email) async {
    try {
      final response = await http
          .post(
        Uri.parse('$baseUrl/auth/forgot_password'),
        headers: _getHeaders(),
        body: json.encode({'email': email}),
      )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map<String, dynamic> && data['token'] is String && data['email'] == email) {
          return data['token'] as String;
        }
        throw 'Invalid response format: token missing or not a string';
      } else if (response.statusCode == 400) {
        final data = json.decode(response.body);
        throw data['message'] ?? 'Failed to generate reset token';
      } else if (response.statusCode == 404) {
        throw 'Email not found';
      } else {
        throw 'Forgot password failed: ${response.statusCode}';
      }
    } on SocketException {
      throw 'No internet connection';
    } on TimeoutException {
      throw 'Request timed out';
    } on FormatException {
      throw 'Invalid JSON response';
    } catch (e) {
      throw 'An unexpected error occurred: $e';
    }
  }

  /// Resets the password using the provided token
  static Future<Map<String, dynamic>> resetPassword(
      String email, String token, String password, String passwordConfirmation) async {
    try {
      final response = await http
          .post(
        Uri.parse('$baseUrl/auth/reset_password'),
        headers: _getHeaders(),
        body: json.encode({
          'email': email,
          'token': token,
          'password': password,
          'password_confirmation': passwordConfirmation,
        }),
      )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map<String, dynamic> && data['message'] is String) {
          return data;
        }
        throw 'Invalid response format';
      } else if (response.statusCode == 400) {
        final data = json.decode(response.body);
        throw data['message'] ?? 'Invalid or expired reset token';
      } else {
        throw 'Reset password failed: ${response.statusCode}';
      }
    } on SocketException {
      throw 'No internet connection';
    } on TimeoutException {
      throw 'Request timed out';
    } on FormatException {
      throw 'Invalid JSON response';
    } catch (e) {
      throw 'An unexpected error occurred: $e';
    }
  }

  /// Verifies the user's email using ID and hash
  static Future<Map<String, dynamic>> verifyEmail(String id, String hash) async {
    try {
      final response = await http
          .get(
        Uri.parse('$baseUrl/auth/email/verify/$id/$hash'),
        headers: _getHeaders(),
      )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map<String, dynamic>) {
          return data;
        }
        throw 'Invalid response format';
      } else {
        throw 'Email verification failed: ${response.statusCode}';
      }
    } on SocketException {
      throw 'No internet connection';
    } on TimeoutException {
      throw 'Request timed out';
    } on FormatException {
      throw 'Invalid JSON response';
    } catch (e) {
      throw 'An unexpected error occurred';
    }
  }

  /// Resends the verification email
  static Future<Map<String, dynamic>> resendVerificationEmail() async {
    if (_token == null) throw 'Not authenticated';
    try {
      final response = await http
          .post(
        Uri.parse('$baseUrl/auth/email/verify/resend'),
        headers: _getHeaders(),
      )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map<String, dynamic>) {
          return data;
        }
        throw 'Invalid response format';
      } else {
        throw 'Resend verification email failed: ${response.statusCode}';
      }
    } on SocketException {
      throw 'No internet connection';
    } on TimeoutException {
      throw 'Request timed out';
    } on FormatException {
      throw 'Invalid JSON response';
    } catch (e) {
      rethrow;
    }
  }

  /// Logs out the authenticated user and clears the token
  static Future<void> logout() async {
    if (_token == null) throw 'Not authenticated';
    try {
      final response = await http
          .post(
        Uri.parse('$baseUrl/auth/logout'),
        headers: _getHeaders(),
      )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        _token = null;
      } else {
        throw 'Logout failed: ${response.statusCode}';
      }
    } on SocketException {
      throw 'No internet connection';
    } on TimeoutException {
      throw 'Request timed out';
    } catch (e) {
      throw 'An unexpected error occurred';
    }
  }

  /// Fetches the authenticated user's details
  static Future<Map<String, dynamic>> getAuthenticatedUser() async {
    if (_token == null) throw 'Not authenticated';
    try {
      final response = await http
          .get(
        Uri.parse('$baseUrl/auth/me'),
        headers: _getHeaders(),
      )
          .timeout(const Duration(seconds: 10));

      print('getAuthenticatedUser Response status: ${response.statusCode}');
      print('getAuthenticatedUser Response headers: ${response.headers}');
      print('getAuthenticatedUser Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map<String, dynamic>) {
          return data;
        }
        throw 'Invalid response format';
      } else {
        throw 'Failed to load user: ${response.statusCode}';
      }
    } on SocketException {
      throw 'No internet connection';
    } on TimeoutException {
      throw 'Request timed out';
    } on FormatException {
      throw 'Invalid JSON response';
    } catch (e) {
      throw 'An unexpected error occurred';
    }
  }

  /// Fetches all device types
  static Future<List<Map<String, dynamic>>> getDeviceTypes() async {
    if (_token == null) throw 'Not authenticated';
    try {
      final response = await http
          .get(
        Uri.parse('$baseUrl/device_types'),
        headers: _getHeaders(),
      )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        }
        throw 'Invalid response format';
      } else {
        throw 'Failed to load device types: ${response.statusCode}';
      }
    } on SocketException {
      throw 'No internet connection';
    } on TimeoutException {
      throw 'Request timed out';
    } on FormatException {
      throw 'Invalid JSON response';
    } catch (e) {
      throw 'An unexpected error occurred';
    }
  }

  /// Fetches all service types
  static Future<List<Map<String, dynamic>>> getServiceTypes() async {
    if (_token == null) throw 'Not authenticated';
    try {
      final response = await http
          .get(
        Uri.parse('$baseUrl/service_types'),
        headers: _getHeaders(),
      )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        }
        throw 'Invalid response format';
      } else {
        throw 'Failed to load service types: ${response.statusCode}';
      }
    } on SocketException {
      throw 'No internet connection';
    } on TimeoutException {
      throw 'Request timed out';
    } on FormatException {
      throw 'Invalid JSON response';
    } catch (e) {
      throw 'An unexpected error occurred';
    }
  }

  /// Fetches all towns
  static Future<List<Map<String, dynamic>>> getTowns() async {
    if (_token == null) throw 'Not authenticated';
    try {
      final response = await http
          .get(
        Uri.parse('$baseUrl/towns'),
        headers: _getHeaders(),
      )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        }
        throw 'Invalid response format';
      } else {
        throw 'Failed to load towns: ${response.statusCode}';
      }
    } on SocketException {
      throw 'No internet connection';
    } on TimeoutException {
      throw 'Request timed out';
    } on FormatException {
      throw 'Invalid JSON response';
    } catch (e) {
      throw 'An unexpected error occurred';
    }
  }

  /// Fetches all clusters
  static Future<List<Map<String, dynamic>>> getClusters() async {
    if (_token == null) throw 'Not authenticated';
    try {
      final response = await http
          .get(
        Uri.parse('$baseUrl/clusters'),
        headers: _getHeaders(),
      )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        }
        throw 'Invalid response format';
      } else {
        throw 'Failed to load clusters: ${response.statusCode}';
      }
    } on SocketException {
      throw 'No internet connection';
    } on TimeoutException {
      throw 'Request timed out';
    } on FormatException {
      throw 'Invalid JSON response';
    } catch (e) {
      throw 'An unexpected error occurred';
    }
  }

  /// Fetches all sites
  static Future<List<Map<String, dynamic>>> getSites() async {
    if (_token == null) throw 'Not authenticated';
    try {
      final response = await http
          .get(
        Uri.parse('$baseUrl/sites'),
        headers: _getHeaders(),
      )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        }
        throw 'Invalid response format';
      } else {
        throw 'Failed to load sites: ${response.statusCode}';
      }
    } on SocketException {
      throw 'No internet connection';
    } on TimeoutException {
      throw 'Request timed out';
    } on FormatException {
      throw 'Invalid JSON response';
    } catch (e) {
      throw 'An unexpected error occurred';
    }
  }

  /// Creates a new site
  static Future<Map<String, dynamic>> createSite(Map<String, dynamic> siteData) async {
    if (_token == null) throw 'Not authenticated';
    try {
      final response = await http
          .post(
        Uri.parse('$baseUrl/sites'),
        headers: _getHeaders(),
        body: json.encode(siteData),
      )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data is Map<String, dynamic>) {
          return data;
        }
        throw 'Invalid response format';
      } else {
        throw 'Failed to create site: ${response.statusCode}';
      }
    } on SocketException {
      throw 'No internet connection';
    } on TimeoutException {
      throw 'Request timed out';
    } on FormatException {
      throw 'Invalid JSON response';
    } catch (e) {
      throw 'An unexpected error occurred';
    }
  }

  /// Fetches a specific site by ID
  static Future<Map<String, dynamic>> getSite(String id) async {
    if (_token == null) throw 'Not authenticated';
    try {
      final response = await http
          .get(
        Uri.parse('$baseUrl/sites/$id'),
        headers: _getHeaders(),
      )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map<String, dynamic>) {
          return data;
        }
        throw 'Invalid response format';
      } else {
        throw 'Failed to load site: ${response.statusCode}';
      }
    } on SocketException {
      throw 'No internet connection';
    } on TimeoutException {
      throw 'Request timed out';
    } on FormatException {
      throw 'Invalid JSON response';
    } catch (e) {
      throw 'An unexpected error occurred';
    }
  }

  /// Updates a specific site by ID
  static Future<Map<String, dynamic>> updateSite(String id, Map<String, dynamic> siteData) async {
    if (_token == null) throw 'Not authenticated';
    try {
      final response = await http
          .put(
        Uri.parse('$baseUrl/sites/$id'),
        headers: _getHeaders(),
        body: json.encode(siteData),
      )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map<String, dynamic>) {
          return data;
        }
        throw 'Invalid response format';
      } else {
        throw 'Failed to update site: ${response.statusCode}';
      }
    } on SocketException {
      throw 'No internet connection';
    } on TimeoutException {
      throw 'Request timed out';
    } on FormatException {
      throw 'Invalid JSON response';
    } catch (e) {
      throw 'An unexpected error occurred';
    }
  }

  /// Deletes a specific site by ID
  static Future<Map<String, dynamic>> deleteSite(String id) async {
    if (_token == null) throw 'Not authenticated';
    try {
      final response = await http
          .delete(
        Uri.parse('$baseUrl/sites/$id'),
        headers: _getHeaders(),
      )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map<String, dynamic>) {
          return data;
        }
        throw 'Invalid response format';
      } else {
        throw 'Failed to delete site: ${response.statusCode}';
      }
    } on SocketException {
      throw 'No internet connection';
    } on TimeoutException {
      throw 'Request timed out';
    } on FormatException {
      throw 'Invalid JSON response';
    } catch (e) {
      throw 'An unexpected error occurred';
    }
  }

  /// Fetches all leads
  static Future<List<Map<String, dynamic>>> getLeads() async {
    if (_token == null) throw 'Not authenticated';
    try {
      final response = await http
          .get(
        Uri.parse('$baseUrl/leads'),
        headers: _getHeaders(),
      )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        }
        throw 'Invalid response format';
      } else {
        throw 'Failed to load leads: ${response.statusCode}';
      }
    } on SocketException {
      throw 'No internet connection';
    } on TimeoutException {
      throw 'Request timed out';
    } on FormatException {
      throw 'Invalid JSON response';
    } catch (e) {
      throw 'An unexpected error occurred';
    }
  }

  /// Creates a new lead
  static Future<Map<String, dynamic>> createLead(Map<String, dynamic> leadData) async {
    if (_token == null) throw 'Not authenticated';
    try {
      final response = await http
          .post(
        Uri.parse('$baseUrl/leads'),
        headers: _getHeaders(),
        body: json.encode(leadData),
      )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data is Map<String, dynamic>) {
          return data;
        }
        throw 'Invalid response format';
      } else {
        throw 'Failed to create lead: ${response.statusCode}';
      }
    } on SocketException {
      throw 'No internet connection';
    } on TimeoutException {
      throw 'Request timed out';
    } on FormatException {
      throw 'Invalid JSON response';
    } catch (e) {
      throw 'An unexpected error occurred';
    }
  }

  /// Updates a specific lead by ID
  static Future<Map<String, dynamic>> updateLead(String id, Map<String, dynamic> leadData) async {
    if (_token == null) throw 'Not authenticated';
    try {
      final response = await http
          .put(
        Uri.parse('$baseUrl/leads/$id'),
        headers: _getHeaders(),
        body: json.encode(leadData),
      )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map<String, dynamic>) {
          return data;
        }
        throw 'Invalid response format';
      } else {
        throw 'Failed to update lead: ${response.statusCode}';
      }
    } on SocketException {
      throw 'No internet connection';
    } on TimeoutException {
      throw 'Request timed out';
    } on FormatException {
      throw 'Invalid JSON response';
    } catch (e) {
      throw 'An unexpected error occurred';
    }
  }

  /// Deletes a specific lead by ID
  static Future<Map<String, dynamic>> deleteLead(String id) async {
    if (_token == null) throw 'Not authenticated';
    try {
      final response = await http
          .delete(
        Uri.parse('$baseUrl/leads/$id'),
        headers: _getHeaders(),
      )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map<String, dynamic>) {
          return data;
        }
        throw 'Invalid response format';
      } else {
        throw 'Failed to delete lead: ${response.statusCode}';
      }
    } on SocketException {
      throw 'No internet connection';
    } on TimeoutException {
      throw 'Request timed out';
    } on FormatException {
      throw 'Invalid JSON response';
    } catch (e) {
      throw 'An unexpected error occurred';
    }
  }

  /// Fetches all customers
  static Future<List<Map<String, dynamic>>> getCustomers() async {
    if (_token == null) throw 'Not authenticated';
    try {
      final response = await http
          .get(
        Uri.parse('$baseUrl/customers'),
        headers: _getHeaders(),
      )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        }
        throw 'Invalid response format';
      } else {
        throw 'Failed to load customers: ${response.statusCode}';
      }
    } on SocketException {
      throw 'No internet connection';
    } on TimeoutException {
      throw 'Request timed out';
    } on FormatException {
      throw 'Invalid JSON response';
    } catch (e) {
      throw 'An unexpected error occurred';
    }
  }

  /// Creates a new customer
  static Future<Map<String, dynamic>> createCustomer(Map<String, dynamic> customerData) async {
    if (_token == null) throw 'Not authenticated';
    try {
      final response = await http
          .post(
        Uri.parse('$baseUrl/customers'),
        headers: _getHeaders(),
        body: json.encode(customerData),
      )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data is Map<String, dynamic>) {
          return data;
        }
        throw 'Invalid response format';
      } else {
        throw 'Failed to create customer: ${response.statusCode}';
      }
    } on SocketException {
      throw 'No internet connection';
    } on TimeoutException {
      throw 'Request timed out';
    } on FormatException {
      throw 'Invalid JSON response';
    } catch (e) {
      throw 'An unexpected error occurred';
    }
  }

  /// Updates a specific customer by ID
  static Future<Map<String, dynamic>> updateCustomer(
      String id, Map<String, dynamic> customerData) async {
    if (_token == null) throw 'Not authenticated';
    try {
      final response = await http
          .put(
        Uri.parse('$baseUrl/customers/$id'),
        headers: _getHeaders(),
        body: json.encode(customerData),
      )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map<String, dynamic>) {
          return data;
        }
        throw 'Invalid response format';
      } else {
        throw 'Failed to update customer: ${response.statusCode}';
      }
    } on SocketException {
      throw 'No internet connection';
    } on TimeoutException {
      throw 'Request timed out';
    } on FormatException {
      throw 'Invalid JSON response';
    } catch (e) {
      throw 'An unexpected error occurred';
    }
  }

  /// Deletes a specific customer by ID
  static Future<Map<String, dynamic>> deleteCustomer(String id) async {
    if (_token == null) throw 'Not authenticated';
    try {
      final response = await http
          .delete(
        Uri.parse('$baseUrl/customers/$id'),
        headers: _getHeaders(),
      )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map<String, dynamic>) {
          return data;
        }
        throw 'Invalid response format';
      } else {
        throw 'Failed to delete customer: ${response.statusCode}';
      }
    } on SocketException {
      throw 'No internet connection';
    } on TimeoutException {
      throw 'Request timed out';
    } on FormatException {
      throw 'Invalid JSON response';
    } catch (e) {
      throw 'An unexpected error occurred';
    }
  }

  /// Fetches all tickets
  static Future<List<Map<String, dynamic>>> getTickets() async {
    if (_token == null) throw 'Not authenticated';
    try {
      final response = await http
          .get(
        Uri.parse('$baseUrl/tickets'),
        headers: _getHeaders(),
      )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        }
        throw 'Invalid response format';
      } else {
        throw 'Failed to load tickets: ${response.statusCode}';
      }
    } on SocketException {
      throw 'No internet connection';
    } on TimeoutException {
      throw 'Request timed out';
    } on FormatException {
      throw 'Invalid JSON response';
    } catch (e) {
      throw 'An unexpected error occurred';
    }
  }

  /// Creates a new ticket
  static Future<Map<String, dynamic>> createTicket(Map<String, dynamic> ticketData) async {
    if (_token == null) throw 'Not authenticated';
    try {
      final response = await http
          .post(
        Uri.parse('$baseUrl/tickets'),
        headers: _getHeaders(),
        body: json.encode(ticketData),
      )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data is Map<String, dynamic>) {
          return data;
        }
        throw 'Invalid response format';
      } else {
        throw 'Failed to create ticket: ${response.statusCode}';
      }
    } on SocketException {
      throw 'No internet connection';
    } on TimeoutException {
      throw 'Request timed out';
    } on FormatException {
      throw 'Invalid JSON response';
    } catch (e) {
      throw 'An unexpected error occurred';
    }
  }

  /// Updates a specific ticket by ID
  static Future<Map<String, dynamic>> updateTicket(
      String id, Map<String, dynamic> ticketData) async {
    if (_token == null) throw 'Not authenticated';
    try {
      final response = await http
          .put(
        Uri.parse('$baseUrl/tickets/$id'),
        headers: _getHeaders(),
        body: json.encode(ticketData),
      )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map<String, dynamic>) {
          return data;
        }
        throw 'Invalid response format';
      } else {
        throw 'Failed to update ticket: ${response.statusCode}';
      }
    } on SocketException {
      throw 'No internet connection';
    } on TimeoutException {
      throw 'Request timed out';
    } on FormatException {
      throw 'Invalid JSON response';
    } catch (e) {
      throw 'An unexpected error occurred';
    }
  }

  /// Deletes a specific ticket by ID
  static Future<Map<String, dynamic>> deleteTicket(String id) async {
    if (_token == null) throw 'Not authenticated';
    try {
      final response = await http
          .delete(
        Uri.parse('$baseUrl/tickets/$id'),
        headers: _getHeaders(),
      )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map<String, dynamic>) {
          return data;
        }
        throw 'Invalid response format';
      } else {
        throw 'Failed to delete ticket: ${response.statusCode}';
      }
    } on SocketException {
      throw 'No internet connection';
    } on TimeoutException {
      throw 'Request timed out';
    } on FormatException {
      throw 'Invalid JSON response';
    } catch (e) {
      throw 'An unexpected error occurred';
    }
  }

  /// Fetches all notifications
  static Future<List<Map<String, dynamic>>> getNotifications() async {
    if (_token == null) throw 'Not authenticated';
    try {
      final response = await http
          .get(
        Uri.parse('$baseUrl/notifications'),
        headers: _getHeaders(),
      )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        }
        throw 'Invalid response format';
      } else {
        throw 'Failed to load notifications: ${response.statusCode}';
      }
    } on SocketException {
      throw 'No internet connection';
    } on TimeoutException {
      throw 'Request timed out';
    } on FormatException {
      throw 'Invalid JSON response';
    } catch (e) {
      throw 'An unexpected error occurred';
    }
  }
}