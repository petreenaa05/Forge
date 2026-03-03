/// Fully dummy auth service — no Firebase Auth at all.
/// Generates a stable UID from the phone number for Firestore use.
class AuthService {
  String? _uid;
  String? _phone;

  String? get currentUid => _uid;
  String? get currentPhone => _phone;

  /// Simulates sending OTP — just stores the phone and calls back.
  Future<void> sendOtp({
    required String phone,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
  }) async {
    _phone = phone;
    await Future.delayed(const Duration(milliseconds: 400));
    onCodeSent('demo-verification-id');
  }

  /// Accepts any OTP and generates a deterministic UID from the phone number.
  Future<String> verifyOtp({
    required String verificationId,
    required String otp,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Create a stable UID from phone so the same number always gets the
    // same Firestore user document.
    _uid = 'user_${_phone?.replaceAll(RegExp(r'[^0-9]'), '') ?? 'unknown'}';
    return _uid!;
  }

  void signOut() {
    _uid = null;
    _phone = null;
  }
}
