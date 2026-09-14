import 'dart:async';
import 'package:flutter/material.dart';
import '../models/user_profile_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  StreamSubscription<UserProfileModel?>? _authSubscription;

  UserProfileModel? _currentUser;
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _errorMessage;

  AuthProvider({AuthService? authService})
    : _authService = authService ?? FirebaseAuthService() {
  _initUser();
}

  UserProfileModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get errorMessage => _errorMessage;

  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  void _initUser() {
    _authSubscription = _authService.authStateChanges.listen(
      (user) {
        _currentUser = user;
        _isInitialized = true;
        _isLoading = false;
        notifyListeners();
      },
      onError: (_) {
        _currentUser = null;
        _isInitialized = true;
        _isLoading = false;
        notifyListeners();
      },
    );

    _authService.getCurrentUser().then((user) {
      _currentUser = user;
      _isInitialized = true;
      notifyListeners();
    }).catchError((_) {
      _isInitialized = true;
      notifyListeners();
    });
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final user = await _authService.signInWithEmail(email, password);
      _currentUser = user;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final user = await _authService.registerWithEmail(name, email, password);
      _currentUser = user;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

Future<bool> signInWithGoogle() async {
  _isLoading = true;
  _errorMessage = null;
  notifyListeners();

  try {
    final user = await _authService.signInWithGoogle();

    _currentUser = user;
    _isLoading = false;
    notifyListeners();

    return true;
  } catch (e) {
    _errorMessage = e.toString().replaceAll('Exception: ', '');
    _isLoading = false;
    notifyListeners();

    return false;
  }
}

  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _authService.sendPasswordResetEmail(email);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authService.signOut();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _currentUser = null;
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
