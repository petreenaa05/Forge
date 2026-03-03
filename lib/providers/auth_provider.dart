import 'package:flutter/foundation.dart';
import 'package:forge/services/auth_service.dart';

/// Fully dummy auth provider — no Firebase Auth dependency.
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  String? _uid;
  String? _phone;
  bool _isLoading = false;
  String? _verificationId;
  String? _error;

  String? get uid => _uid;
  String? get phone => _phone;
  bool get isLoading => _isLoading;
  String? get verificationId => _verificationId;
  String? get error => _error;
  bool get isLoggedIn => _uid != null;

  Future<void> sendOtp(String phone) async {
    _isLoading = true;
    _error = null;
    _phone = phone;
    notifyListeners();

    await _authService.sendOtp(
      phone: phone,
      onCodeSent: (vid) {
        _verificationId = vid;
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        _error = e;
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<bool> verifyOtp(String otp) async {
    if (_verificationId == null) return false;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _uid = await _authService.verifyOtp(
        verificationId: _verificationId!,
        otp: otp,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    _authService.signOut();
    _uid = null;
    _phone = null;
    _verificationId = null;
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Set user after email/password login
  void setLoginUser({required String uid, String? email}) {
    _uid = uid;
    _phone = email; // Using phone field for email in this case
    notifyListeners();
  }
}
