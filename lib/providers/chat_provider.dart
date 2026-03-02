import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:forge/models/chat_message_model.dart';
import 'package:forge/models/chat_model.dart';
import 'package:forge/services/chat_service.dart';

/// State management for the entire chat system.
///
/// Manages:
/// - Active chat session lifecycle (open, close, dispose)
/// - Message composition and sending (text, image)
/// - Image picking and upload state
/// - Typing indicator updates
/// - Read receipt triggers
/// - Presence management (online/offline, active chat)
class ChatProvider extends ChangeNotifier {
  final ChatService _chatService = ChatService();
  final ImagePicker _imagePicker = ImagePicker();

  // ── State ─────────────────────────────────────────────
  String? _activeChatId;
  String? _activeOtherUid;
  String? _activeOtherName;
  String? _activeOtherImage;
  bool _isSending = false;
  bool _isUploadingImage = false;
  double _uploadProgress = 0.0;
  String? _errorMessage;
  List<MessageModel> _olderMessages = [];
  bool _hasMoreMessages = true;
  bool _isLoadingMore = false;

  // ── Getters ───────────────────────────────────────────
  String? get activeChatId => _activeChatId;
  String? get activeOtherUid => _activeOtherUid;
  String? get activeOtherName => _activeOtherName;
  String? get activeOtherImage => _activeOtherImage;
  bool get isSending => _isSending;
  bool get isUploadingImage => _isUploadingImage;
  double get uploadProgress => _uploadProgress;
  String? get errorMessage => _errorMessage;
  List<MessageModel> get olderMessages => _olderMessages;
  bool get hasMoreMessages => _hasMoreMessages;
  bool get isLoadingMore => _isLoadingMore;
  ChatService get service => _chatService;

  // ════════════════════════════════════════════════════════
  // CONVERSATION LIFECYCLE
  // ════════════════════════════════════════════════════════

  Future<String?> openChat({
    required String myUid,
    required String myName,
    required String myImage,
    required String otherUid,
    required String otherName,
    required String otherImage,
    String? jobId,
  }) async {
    try {
      _errorMessage = null;

      final chatId = await _chatService.getOrCreateChat(
        myUid: myUid,
        myName: myName,
        myImage: myImage,
        otherUid: otherUid,
        otherName: otherName,
        otherImage: otherImage,
        jobId: jobId,
      );

      _activeChatId = chatId;
      _activeOtherUid = otherUid;
      _activeOtherName = otherName;
      _activeOtherImage = otherImage;
      _olderMessages = [];
      _hasMoreMessages = true;

      await _chatService.setOnline(uid: myUid, activeChat: chatId);

      await _chatService.markMessagesAsRead(
        chatId: chatId,
        myUid: myUid,
      );

      notifyListeners();
      return chatId;
    } catch (e) {
      _errorMessage = 'Failed to open conversation.';
      notifyListeners();
      return null;
    }
  }

  Future<void> closeChat(String myUid) async {
    if (_activeChatId != null) {
      await _chatService.clearTyping(
        chatId: _activeChatId!,
        uid: myUid,
      );
      await _chatService.setOnline(uid: myUid, activeChat: null);
    }

    _activeChatId = null;
    _activeOtherUid = null;
    _activeOtherName = null;
    _activeOtherImage = null;
    _olderMessages = [];
    notifyListeners();
  }

  // ════════════════════════════════════════════════════════
  // SENDING MESSAGES
  // ════════════════════════════════════════════════════════

  Future<bool> sendTextMessage({
    required String senderId,
    required String message,
  }) async {
    if (_activeChatId == null || message.trim().isEmpty) return false;

    _isSending = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _chatService.sendTextMessage(
        chatId: _activeChatId!,
        senderId: senderId,
        message: message.trim(),
      );
      _isSending = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isSending = false;
      _errorMessage = 'Failed to send message.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> pickAndSendImage({
    required String senderId,
    ImageSource source = ImageSource.gallery,
  }) async {
    if (_activeChatId == null) return false;

    try {
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 70,
      );

      if (pickedFile == null) return false;

      _isUploadingImage = true;
      _uploadProgress = 0.0;
      _errorMessage = null;
      notifyListeners();

      final imageBytes = await pickedFile.readAsBytes();

      await _chatService.sendImageMessage(
        chatId: _activeChatId!,
        senderId: senderId,
        imageBytes: imageBytes,
      );

      _isUploadingImage = false;
      _uploadProgress = 1.0;
      notifyListeners();
      return true;
    } catch (e) {
      _isUploadingImage = false;
      _errorMessage = 'Failed to send image.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> sendJobUpdate({
    required String chatId,
    required String senderId,
    required String jobTitle,
    required String newStatus,
  }) async {
    try {
      await _chatService.sendJobUpdateMessage(
        chatId: chatId,
        senderId: senderId,
        jobTitle: jobTitle,
        newStatus: newStatus,
      );
      return true;
    } catch (e) {
      _errorMessage = 'Failed to send job update.';
      notifyListeners();
      return false;
    }
  }

  // ════════════════════════════════════════════════════════
  // PAGINATION
  // ════════════════════════════════════════════════════════

  Future<void> loadMoreMessages(DateTime oldestTimestamp) async {
    if (_activeChatId == null || !_hasMoreMessages || _isLoadingMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final older = await _chatService.loadOlderMessages(
        _activeChatId!,
        beforeTimestamp: oldestTimestamp,
        limit: 25,
      );

      if (older.isEmpty) {
        _hasMoreMessages = false;
      } else {
        _olderMessages = [...older, ..._olderMessages];
      }

      _isLoadingMore = false;
      notifyListeners();
    } catch (e) {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  // ════════════════════════════════════════════════════════
  // TYPING INDICATOR
  // ════════════════════════════════════════════════════════

  void onTyping(String uid) {
    if (_activeChatId == null) return;
    _chatService.setTyping(
      chatId: _activeChatId!,
      uid: uid,
      isTyping: true,
    );
  }

  void onStopTyping(String uid) {
    if (_activeChatId == null) return;
    _chatService.setTyping(
      chatId: _activeChatId!,
      uid: uid,
      isTyping: false,
    );
  }

  // ════════════════════════════════════════════════════════
  // READ RECEIPTS
  // ════════════════════════════════════════════════════════

  Future<void> markAsRead(String myUid) async {
    if (_activeChatId == null) return;
    await _chatService.markMessagesAsRead(
      chatId: _activeChatId!,
      myUid: myUid,
    );
  }

  // ════════════════════════════════════════════════════════
  // PRESENCE
  // ════════════════════════════════════════════════════════

  Future<void> goOnline(String uid) async {
    await _chatService.setOnline(uid: uid);
  }

  Future<void> goOffline(String uid) async {
    await _chatService.setOffline(uid);
  }

  // ════════════════════════════════════════════════════════
  // STREAMS
  // ════════════════════════════════════════════════════════

  Stream<List<MessageModel>>? get activeMessages {
    if (_activeChatId == null) return null;
    return _chatService.streamMessages(_activeChatId!);
  }

  Stream<ChatModel?>? get activeChatStream {
    if (_activeChatId == null) return null;
    return _chatService.streamChat(_activeChatId!);
  }

  Stream<UserPresence>? get otherUserPresence {
    if (_activeOtherUid == null) return null;
    return _chatService.streamPresence(_activeOtherUid!);
  }

  Stream<List<ChatModel>> userChats(String uid) =>
      _chatService.streamUserChats(uid);

  Stream<int> totalUnread(String uid) =>
      _chatService.streamTotalUnread(uid);

  // ════════════════════════════════════════════════════════
  // CLEANUP
  // ════════════════════════════════════════════════════════

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _chatService.dispose();
    super.dispose();
  }
}
