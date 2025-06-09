import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://ogdms.extrock.com/api';
  static String? _token;

  //
  // ===========================================================================
  // CORE PRIVATE HELPERS
  // ===========================================================================
  //

  /// Returns the standard headers for all requests, including the auth token if available.
  static Map<String, String> _getHeaders() => {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  /// A central method to handle all HTTP requests.
  /// It manages making the request, handling success, and processing all errors.
  static Future<dynamic> _makeRequest(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    if (requiresAuth && _token == null) {
      throw 'Authentication error. Please log in.';
    }

    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final headers = _getHeaders();
      final encodedBody = body != null ? json.encode(body) : null;
      http.Response response;

      switch (method.toUpperCase()) {
        case 'POST':
          response = await http.post(uri, headers: headers, body: encodedBody).timeout(const Duration(seconds: 15));
          break;
        case 'PUT':
          response = await http.put(uri, headers: headers, body: encodedBody).timeout(const Duration(seconds: 15));
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: headers, body: encodedBody).timeout(const Duration(seconds: 15));
          break;
        case 'GET':
        default:
          response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 15));
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // For successful requests with no content (like a 204), return null.
        if (response.body.isEmpty) return null;
        return json.decode(response.body);
      } else {
        throw _handleErrorResponse(response);
      }
    } on SocketException {
      throw 'No Internet Connection. Please check your network and try again.';
    } on TimeoutException {
      throw 'The server took too long to respond. Please try again later.';
    } catch (e) {
      if (e is String) rethrow; // Re-throw custom parsed errors.
      throw 'An unexpected error occurred: $e';
    }
  }

  /// Parses detailed error messages from a failed HTTP response.
  static String _handleErrorResponse(http.Response response) {
    try {
      final errorData = json.decode(response.body) as Map<String, dynamic>;
      if (errorData.containsKey('errors')) {
        final errors = errorData['errors'] as Map<String, dynamic>;
        return errors.values.first[0];
      }
      if (errorData.containsKey('message')) return errorData['message'];
      if (errorData.containsKey('error')) return errorData['error'];
    } catch (_) {
      // Fallback if the body isn't JSON or doesn't match expected structure.
    }
    return 'Request failed with status: ${response.statusCode}';
  }

  //
  // ===========================================================================
  // PUBLIC API METHODS
  // ===========================================================================
  //

  // --- Authentication ---

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final responseData = await _makeRequest(
      'POST',
      '/auth/login',
      body: {'email': email, 'password': password},
      requiresAuth: false,
    );
    _token = responseData['access_token'];
    return responseData as Map<String, dynamic>;
  }

  static Future<void> logout() async {
    await _makeRequest('POST', '/auth/logout');
    _token = null;
  }

  static Future<Map<String, dynamic>> getAuthenticatedUser() async {
    final response = await _makeRequest('GET', '/auth/me');
    return response as Map<String, dynamic>;
  }

  // --- Password & Email Verification ---

  static Future<String> forgotPassword(String email) async {
    final responseData = await _makeRequest(
      'POST',
      '/auth/forgot_password',
      body: {'email': email},
      requiresAuth: false,
    );
    // Matching the original method's return type.
    return responseData['token'] as String;
  }

  static Future<Map<String, dynamic>> resetPassword(String email, String token, String password, String passwordConfirmation) async {
    final response = await _makeRequest(
      'POST',
      '/auth/reset_password',
      body: {'email': email, 'token': token, 'password': password, 'password_confirmation': passwordConfirmation},
      requiresAuth: false,
    );
    return response as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> verifyEmail(String id, String hash) async {
    final response = await _makeRequest('GET', '/auth/email/verify/$id/$hash', requiresAuth: false);
    return response as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> resendVerificationEmail() async {
    final response = await _makeRequest('POST', '/auth/email/verify/resend');
    return response as Map<String, dynamic>;
  }

  // --- Generic Data Endpoints (GET Lists) ---
  
  static Future<List<Map<String, dynamic>>> getDeviceTypes() async {
    final response = await _makeRequest('GET', '/device_types');
    return List<Map<String, dynamic>>.from(response);
  }

  static Future<List<Map<String, dynamic>>> getServiceTypes() async {
    final response = await _makeRequest('GET', '/service_types');
    return List<Map<String, dynamic>>.from(response);
  }

  static Future<List<Map<String, dynamic>>> getTowns() async {
    final response = await _makeRequest('GET', '/towns');
    return List<Map<String, dynamic>>.from(response);
  }

  static Future<List<Map<String, dynamic>>> getClusters() async {
    final response = await _makeRequest('GET', '/clusters');
    return List<Map<String, dynamic>>.from(response);
  }

  // --- Sites ---

  static Future<List<Map<String, dynamic>>> getSites() async {
    final response = await _makeRequest('GET', '/sites');
    return List<Map<String, dynamic>>.from(response);
  }

  static Future<Map<String, dynamic>> createSite(Map<String, dynamic> siteData) async {
    final response = await _makeRequest('POST', '/sites', body: siteData);
    return response as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> getSite(String id) async {
    final response = await _makeRequest('GET', '/sites/$id');
    return response as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> updateSite(String id, Map<String, dynamic> siteData) async {
    final response = await _makeRequest('PUT', '/sites/$id', body: siteData);
    return response as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> deleteSite(String id) async {
    final response = await _makeRequest('DELETE', '/sites/$id');
    return response as Map<String, dynamic>;
  }

  // --- Leads ---

  static Future<List<Map<String, dynamic>>> getLeads() async {
    final response = await _makeRequest('GET', '/leads');
    return List<Map<String, dynamic>>.from(response);
  }

  static Future<Map<String, dynamic>> createLead(Map<String, dynamic> leadData) async {
    final response = await _makeRequest('POST', '/leads', body: leadData);
    return response as Map<String, dynamic>;
  }
  
  static Future<Map<String, dynamic>> updateLead(String id, Map<String, dynamic> leadData) async {
    final response = await _makeRequest('PUT', '/leads/$id', body: leadData);
    return response as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> deleteLead(String id) async {
    final response = await _makeRequest('DELETE', '/leads/$id');
    return response as Map<String, dynamic>;
  }

  // --- Customers ---

  static Future<List<Map<String, dynamic>>> getCustomers() async {
    final response = await _makeRequest('GET', '/customers');
    return List<Map<String, dynamic>>.from(response);
  }

  static Future<Map<String, dynamic>> createCustomer(Map<String, dynamic> customerData) async {
    final response = await _makeRequest('POST', '/customers', body: customerData);
    return response as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> updateCustomer(String id, Map<String, dynamic> customerData) async {
    final response = await _makeRequest('PUT', '/customers/$id', body: customerData);
    return response as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> deleteCustomer(String id) async {
    final response = await _makeRequest('DELETE', '/customers/$id');
    return response as Map<String, dynamic>;
  }

  // --- Tickets ---

  static Future<List<Map<String, dynamic>>> getTickets() async {
    final response = await _makeRequest('GET', '/tickets');
    return List<Map<String, dynamic>>.from(response);
  }

  static Future<Map<String, dynamic>> createTicket(Map<String, dynamic> ticketData) async {
  final filteredTicketData = {
    'customer_id': ticketData['customer_id'],
    'service_type_id': ticketData['service_type_id'],
    if (ticketData['notes'] != null && ticketData['notes'].isNotEmpty) 'notes': ticketData['notes'],
  };
  final response = await _makeRequest('POST', '/tickets', body: filteredTicketData);
  return response as Map<String, dynamic>;
}


  static Future<Map<String, dynamic>> updateTicket(String id, Map<String, dynamic> ticketData) async {
    final response = await _makeRequest('PUT', '/tickets/$id', body: ticketData);
    return response as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> deleteTicket(String id) async {
    final response = await _makeRequest('DELETE', '/tickets/$id');
    return response as Map<String, dynamic>;
  }

  // --- Notifications ---
  
  static Future<List<Map<String, dynamic>>> getNotifications() async {
    final response = await _makeRequest('GET', '/notifications');
    return List<Map<String, dynamic>>.from(response);
  }
}