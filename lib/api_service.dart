import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const String baseUrl = 'https://ogdms.extrock.com/api';
  static const _storage = FlutterSecureStorage();

  //
  // ===========================================================================
  // CORE PRIVATE HELPERS
  // ===========================================================================
  //

  /// Returns the standard headers for all requests, reading the auth token from secure storage.
  static Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.read(key: 'auth_token'); // FIXED: Use 'auth_token'
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// A central method to handle all HTTP requests.
  static Future<dynamic> _makeRequest(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final headers = await _getHeaders();
      final encodedBody = body != null ? json.encode(body) : null;
      http.Response response;

      switch (method.toUpperCase()) {
        case 'POST':
          response = await http.post(uri, headers: headers, body: encodedBody).timeout(const Duration(seconds: 15));
          break;
        case 'PUT':
          response = await http.put(uri, headers: headers, body: encodedBody).timeout(const Duration(seconds: 15));
          break;
        case 'GET':
        default:
          response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 15));
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) return null;
        return json.decode(response.body);
      } else {
        final error = _handleErrorResponse(response);
        if (response.statusCode == 401 && error.contains('Unauthenticated')) {
          throw Exception('Unauthenticated');
        }
        throw Exception(error);
      }
    } on SocketException {
      throw Exception('No Internet Connection. Please check your network and try again.');
    } on TimeoutException {
      throw Exception('The server took too long to respond. Please try again later.');
    } catch (e) {
      rethrow;
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
      // Fallback
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
    );
    final token = responseData['access_token'];
    if (token != null) {
      await _storage.write(key: 'auth_token', value: token);
    }
    return responseData as Map<String, dynamic>;
  }

  static Future<void> logout() async {
    try {
      await _makeRequest('POST', '/auth/logout');
    } finally {
      await _storage.delete(key: 'auth_token');
    }
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
    );
    return responseData['token'] as String;
  }

  static Future<Map<String, dynamic>> resetPassword(String email, String token, String password, String passwordConfirmation) async {
    final response = await _makeRequest(
      'POST',
      '/auth/reset_password',
      body: {'email': email, 'token': token, 'password': password, 'password_confirmation': passwordConfirmation},
    );
    return response as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> verifyEmail(String id, String hash) async {
    final response = await _makeRequest('GET', '/auth/email/verify/$id/$hash');
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
    final response = await _makeRequest('POST', '/tickets', body: ticketData);
    return response as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> updateTicket(String id, Map<String, dynamic> ticketData) async {
    final response = await _makeRequest('PUT', '/tickets/$id', body: ticketData);
    return response as Map<String, dynamic>;
  }

  // REMOVED: deleteTicket method as neither dse nor installer should delete tickets

  // --- Notifications ---
  
  static Future<List<Map<String, dynamic>>> getNotifications() async {
    final response = await _makeRequest('GET', '/notifications');
    return List<Map<String, dynamic>>.from(response);
  }
}