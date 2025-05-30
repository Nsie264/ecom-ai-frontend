import 'package:dio/dio.dart';
import '../utils/http_client.dart';
import '../models/user.dart';
import '../models/address.dart';

class AuthApiService {
  final HttpClient _httpClient;

  AuthApiService(this._httpClient);

  /// Login a user with email and password
  /// Returns the access token on success
  Future<String> login(String email, String password) async {
    try {
      // For form-urlencoded, we need to create the data correctly
      final data = {
        'username': email,
        'password': password,
      };

      final response = await _httpClient.post(
        '/auth/login',
        data: data,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        ),
      );

      final String token = response.data['access_token'];
      
      // Save the token for future authenticated requests
      await _httpClient.saveToken(token);
      
      return token;
    } catch (e) {
      _handleError(e, 'Login failed');
      rethrow;
    }
  }

  /// Register a new user with email, password, and full name
  /// Returns the created user on success
  Future<User> register(String email, String password, String fullName) async {
    try {
      final data = {
        'email': email,
        'password': password,
        'full_name': fullName,
      };

      final response = await _httpClient.post('/auth/register', data: data);
      return User.fromJson(response.data);
    } catch (e) {
      _handleError(e, 'Registration failed');
      rethrow;
    }
  }

  /// Get the current user's profile
  /// Requires authentication
  Future<User> getUserProfile() async {
    try {
      final response = await _httpClient.get('/auth/me');
      return User.fromJson(response.data);
    } catch (e) {
      _handleError(e, 'Failed to get user profile');
      rethrow;
    }
  }

  /// Update the current user's profile
  /// Requires authentication
  Future<User> updateUserProfile({String? fullName, String? password}) async {
    try {
      final data = {};

      if (fullName != null) {
        data['full_name'] = fullName;
      }

      if (password != null) {
        data['password'] = password;
      }

      final response = await _httpClient.put('/auth/me', data: data);
      return User.fromJson(response.data);
    } catch (e) {
      _handleError(e, 'Failed to update user profile');
      rethrow;
    }
  }

  /// Get all addresses for the current user
  /// Requires authentication
  Future<List<Address>> getUserAddresses() async {
    try {
      final response = await _httpClient.get('/auth/me/addresses');

      return (response.data as List)
          .map((json) => Address.fromJson(json))
          .toList();
    } catch (e) {
      _handleError(e, 'Failed to get user addresses');
      rethrow;
    }
  }

  /// Add a new address for the current user
  /// Requires authentication
  Future<Address> addAddress(Address address) async {
    try {
      final response = await _httpClient.post(
        '/auth/me/addresses',
        data: address.toJson(),
      );

      return Address.fromJson(response.data);
    } catch (e) {
      _handleError(e, 'Failed to add address');
      rethrow;
    }
  }

  /// Update an existing address
  /// Requires authentication
  Future<Address> updateAddress(int addressId, Address address) async {
    try {
      final response = await _httpClient.put(
        '/auth/addresses/$addressId',
        data: address.toJson(),
      );

      return Address.fromJson(response.data);
    } catch (e) {
      _handleError(e, 'Failed to update address');
      rethrow;
    }
  }

  /// Delete an address
  /// Requires authentication
  Future<bool> deleteAddress(int addressId) async {
    try {
      final response = await _httpClient.delete('/auth/addresses/$addressId');
      return response.data['success'] ?? false;
    } catch (e) {
      _handleError(e, 'Failed to delete address');
      rethrow;
    }
  }

  /// Logout the current user by clearing the token
  Future<void> logout() async {
    await _httpClient.clearToken();
  }

  /// Helper method to handle errors
  void _handleError(dynamic error, String defaultMessage) {
    if (error is DioException) {
      print('${error.response?.statusCode}: ${error.response?.data}');

      // You can add more sophisticated error handling here
      // For example, you could use a SnackBar or Dialog to show the error

      // if (Get.isRegistered<LoadingController>()) {
      //   Get.find<LoadingController>().hideLoading();
      //   Get.snackbar('Error', error.response?.data['detail'] ?? defaultMessage);
      // }
    } else {
      print('Error: $error');
      // If Get is available: Get.snackbar('Error', defaultMessage);
    }
  }
}
