import 'package:flutter/foundation.dart';
import 'package:forge/models/user_model.dart';
import 'package:forge/services/firestore_service.dart';
import 'package:forge/core/constants/app_constants.dart';

class UserProvider extends ChangeNotifier {
  final FirestoreService _db = FirestoreService();
  UserModel? _user;
  bool _isLoading = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String get currentRole => _user?.role ?? UserRole.client;
  bool get isFreelancer => currentRole == UserRole.freelancer;

  Future<void> loadUser(String uid) async {
    _isLoading = true;
    notifyListeners();
    _user = await _db.getUser(uid);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> createUser(UserModel user) async {
    _isLoading = true;
    notifyListeners();
    await _db.createUser(user);
    _user = user;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    await _db.updateUser(uid, data);
    _user = await _db.getUser(uid);
    _isLoading = false;
    notifyListeners();
  }

  /// Toggle between freelancer and client roles.
  Future<void> switchRole(String uid) async {
    final newRole = currentRole == UserRole.freelancer
        ? UserRole.client
        : UserRole.freelancer;
    await _db.updateUser(uid, {'role': newRole});
    _user = _user?.copyWith(role: newRole);
    notifyListeners();
  }

  void clear() {
    _user = null;
    notifyListeners();
  }
}
