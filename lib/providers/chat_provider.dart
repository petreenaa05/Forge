import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

/// Provides real-time unread-message tracking so both client & freelancer
/// screens can show notification badges on the chat icon.
class ChatProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  int _unreadCount = 0;
  StreamSubscription? _chatSub;
  String? _currentUserId;

  int get unreadCount => _unreadCount;
  bool get hasUnread => _unreadCount > 0;

  /// Start listening to all conversations where the user is a participant.
  /// Counts how many conversations have `unreadBy.{uid}` == true.
  void startListening(String userId) {
    if (_currentUserId == userId && _chatSub != null) return;
    _currentUserId = userId;
    _chatSub?.cancel();

    _chatSub = _db
        .collection('chats')
        .where('participants', arrayContains: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      int count = 0;
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final unreadBy = data['unreadBy'] as Map<String, dynamic>? ?? {};
        if (unreadBy[userId] == true) count++;
      }
      _unreadCount = count;
      notifyListeners();
    }, onError: (_) {
      // Firestore index may not exist yet — silently degrade
      _unreadCount = 0;
      notifyListeners();
    });
  }

  /// Mark a conversation as read for the current user.
  Future<void> markAsRead(String chatId) async {
    if (_currentUserId == null) return;
    try {
      await _db.collection('chats').doc(chatId).update({
        'unreadBy.$_currentUserId': false,
      });
    } catch (_) {}
  }

  void stopListening() {
    _chatSub?.cancel();
    _chatSub = null;
    _unreadCount = 0;
    _currentUserId = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _chatSub?.cancel();
    super.dispose();
  }
}
