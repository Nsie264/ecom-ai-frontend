import 'package:get/get.dart';
import '../models/user.dart';
import '../models/address.dart';
import '../services/auth_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthController extends GetxController {
  final AuthApiService _authService;

  // Observable state variables
  final Rx<User?> _currentUser = Rx<User?>(null);
  final RxBool _isLoggedIn = false.obs;
  final RxList<Address> _addresses = <Address>[].obs;
  final RxBool _isLoading = false.obs;

  // Getters for the state
  User? get currentUser => _currentUser.value;
  bool get isLoggedIn => _isLoggedIn.value;
  List<Address> get addresses => _addresses;
  bool get isLoading => _isLoading.value;

  // Constructor
  AuthController(this._authService);

  @override
  void onInit() {
    super.onInit();
    // Check if user is already logged in (e.g., from token stored in secure storage)
    checkInitialAuthState();
  }

  // Make this method public so it can be called from main
  Future<bool> checkInitialAuthState() async {
    _setLoading(true);
    try {
      // Attempt to get user profile using the stored token
      final user = await _authService.getUserProfile();
      if (user != null) {
        _setCurrentUser(user);
        await fetchUserAddresses();
        return true;
      }
      return false;
    } catch (e) {
      // If error occurs, user is not logged in or token is invalid
      print('Not logged in or token expired: $e');
      await _authService.logout(); // Clear any invalid tokens
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Login user
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    try {
      // Authenticate and get token
      final token = await _authService.login(email, password);

      // If we have a token, fetch user profile
      if (token != null && token.isNotEmpty) {
        try {
          final user = await _authService.getUserProfile();
          if (user != null) {
            _setCurrentUser(user);
            await fetchUserAddresses();
            return true;
          }
        } catch (profileError) {
          print('Error fetching user profile after login: $profileError');
        }
      }
      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Register new user
  Future<bool> register(String email, String password, String fullName) async {
    _setLoading(true);
    try {
      final user = await _authService.register(email, password, fullName);

      // After registration, login automatically
      return await login(email, password);
    } catch (e) {
      print('Registration error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get user profile
  Future<void> fetchUserProfile() async {
    _setLoading(true);
    try {
      final user = await _authService.getUserProfile();
      _setCurrentUser(user);
    } catch (e) {
      print('Error fetching user profile: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Update user profile
  Future<bool> updateUserProfile({String? fullName, String? password}) async {
    _setLoading(true);
    try {
      final updatedUser = await _authService.updateUserProfile(
        fullName: fullName,
        password: password,
      );
      _setCurrentUser(updatedUser);
      return true;
    } catch (e) {
      print('Error updating user profile: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get user addresses
  Future<void> fetchUserAddresses() async {
    _setLoading(true);
    try {
      final userAddresses = await _authService.getUserAddresses();
      _addresses.value = userAddresses;
    } catch (e) {
      print('Error fetching addresses: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Add new address
  Future<bool> addAddress(Address address) async {
    _setLoading(true);
    try {
      final addedAddress = await _authService.addAddress(address);
      _addresses.add(addedAddress);
      return true;
    } catch (e) {
      print('Error adding address: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update address
  Future<bool> updateAddress(int addressId, Address address) async {
    _setLoading(true);
    try {
      final updatedAddress = await _authService.updateAddress(
        addressId,
        address,
      );

      // Update the address in the list
      final index = _addresses.indexWhere((a) => a.addressId == addressId);
      if (index != -1) {
        _addresses[index] = updatedAddress;
      }
      return true;
    } catch (e) {
      print('Error updating address: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete address
  Future<bool> deleteAddress(int addressId) async {
    _setLoading(true);
    try {
      final success = await _authService.deleteAddress(addressId);
      if (success) {
        // Remove the address from the list
        _addresses.removeWhere((a) => a.addressId == addressId);
      }
      return success;
    } catch (e) {
      print('Error deleting address: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _authService.logout();
      // Clear local storage
      final storage = FlutterSecureStorage();
      await storage.delete(key: 'auth_token');

      // Reset user state
      _currentUser.value = null;
      _isLoggedIn.value = false;
      _addresses.clear();

      // Navigate to login screen
      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to logout: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Helper methods to update state
  void _setCurrentUser(User user) {
    _currentUser.value = user;
    _isLoggedIn.value = true;
  }

  void _clearUserData() {
    _currentUser.value = null;
    _isLoggedIn.value = false;
    _addresses.clear();
  }

  void _setLoading(bool loading) {
    _isLoading.value = loading;
  }
}
