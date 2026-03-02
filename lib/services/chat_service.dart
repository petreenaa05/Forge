import 'dart:async';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

import 'package:forge/models/chat_message_model.dart';
import 'package:forge/models/chat_model.dart';

class ChatService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final _uuid = const Uuid();

  CollectionReference get _chatsRef => _db.collection('chats');
  CollectionReference get _presenceRef => _db.collection('user_presence');

  CollectionReference _messagesRef(String chatId) =>
      _chatsRef.doc(chatId).collection('messages');

  // ════════════════════════════════════════════════════════
  // 1. CONVERSATION MANAGEMENT
  // ════════════════════════════════════════════════════════

  Future<String> getOrCreateChat({
    required String myUid,
    required String myName,
    required String myImage,
    required String otherUid,
    required String otherName,
    required String otherImage,
    String? jobId,
  }) async {
    try {
      final sortedIds = [myUid, otherUid]..sort();
      final chatId = '${sortedIds[0]}_${sortedIds[1]}';

      final chatDoc = await _chatsRef.doc(chatId).get();

      if (!chatDoc.exists) {
        final chat = ChatModel(
          chatId: chatId,
          participants: sortedIds,
          participantNames: {myUid: myName, otherUid: otherName},
          participantImages: {myUid: myImage, otherUid: otherImage},
          unreadCount: {myUid: 0, otherUid: 0},
          typing: {myUid: false, otherUid: false},
          jobId: jobId,
        );

        await _chatsRef.doc(chatId).set(chat.toMap());

        await _sendSystemMessage(
          chatId: chatId,
          message: 'Conversation started. Say hello! 👋',
        );
      } else {
        await _chatsRef.doc(chatId).update({
          'participantNames.$myUid': myName,
          'participantNames.$otherUid': otherName,
          'participantImages.$myUid': myImage,
          'participantImages.$otherUid': otherImage,
        });
      }

      return chatId;
    } catch (e) {
      throw Exception('Failed to create conversation: $e');
    }
  }

  Stream<List<ChatModel>> streamUserChats(String uid) {
    return _chatsRef
        .where('participants', arrayContains: uid)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                ChatModel.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  Stream<ChatModel?> streamChat(String chatId) {
    return _chatsRef.doc(chatId).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return ChatModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    });
  }

  Stream<int> streamTotalUnread(String uid) {
    return _chatsRef
        .where('participants', arrayContains: uid)
        .snapshots()
        .map((snapshot) {
      int total = 0;
      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final unreadMap = Map<String, int>.from(data['unreadCount'] ?? {});
        total += unreadMap[uid] ?? 0;
      }
      return total;
    });
  }

  // ════════════════════════════════════════════════════════
  // 2. SENDING MESSAGES
  // ════════════════════════════════════════════════════════

  Future<void> sendTextMessage({
    required String chatId,
    required String senderId,
    required String message,
  }) async {
    try {
      final messageId = _uuid.v4();

      final msg = MessageModel(
        messageId: messageId,
        senderId: senderId,
        message: message,
        type: MessageType.text,
        readBy: [senderId],
        status: MessageStatus.sent,
      );

      await _messagesRef(chatId).doc(messageId).set(msg.toMap());

      await _updateChatMetadata(
        chatId: chatId,
        senderId: senderId,
        lastMessage: message,
        lastMessageType: 'text',
      );
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  Future<void> sendImageMessage({
    required String chatId,
    required String senderId,
    required Uint8List imageBytes,
    String caption = '',
  }) async {
    try {
      final messageId = _uuid.v4();

      final storageRef = _storage
          .ref()
          .child('chat_images')
          .child(chatId)
          .child('$messageId.jpg');

      final uploadTask = await storageRef.putData(
        imageBytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      final imageUrl = await uploadTask.ref.getDownloadURL();

      final msg = MessageModel(
        messageId: messageId,
        senderId: senderId,
        message: caption.isNotEmpty ? caption : '📷 Photo',
        type: MessageType.image,
        imageUrl: imageUrl,
        readBy: [senderId],
        status: MessageStatus.sent,
      );

      await _messagesRef(chatId).doc(messageId).set(msg.toMap());

      await _updateChatMetadata(
        chatId: chatId,
        senderId: senderId,
        lastMessage: caption.isNotEmpty ? caption : '📷 Photo',
        lastMessageType: 'image',
      );
    } catch (e) {
      throw Exception('Failed to send image: $e');
    }
  }

  Future<void> sendJobUpdateMessage({
    required String chatId,
    required String senderId,
    required String jobTitle,
    required String newStatus,
  }) async {
    try {
      final messageId = _uuid.v4();

      String displayMessage;
      switch (newStatus) {
        case 'accepted':
          displayMessage = '✅ Job "$jobTitle" has been accepted!';
          break;
        case 'rejected':
          displayMessage = '❌ Job "$jobTitle" was declined.';
          break;
        case 'completed':
          displayMessage = '🎉 Job "$jobTitle" has been completed!';
          break;
        default:
          displayMessage = '📋 Job "$jobTitle" status: $newStatus';
      }

      final msg = MessageModel(
        messageId: messageId,
        senderId: senderId,
        message: displayMessage,
        type: MessageType.jobUpdate,
        jobUpdate: {
          'status': newStatus,
          'jobTitle': jobTitle,
        },
        readBy: [senderId],
        status: MessageStatus.sent,
      );

      await _messagesRef(chatId).doc(messageId).set(msg.toMap());

      await _updateChatMetadata(
        chatId: chatId,
        senderId: senderId,
        lastMessage: displayMessage,
        lastMessageType: 'job_update',
      );
    } catch (e) {
      throw Exception('Failed to send job update: $e');
    }
  }

  Future<void> _sendSystemMessage({
    required String chatId,
    required String message,
  }) async {
    final messageId = _uuid.v4();

    final msg = MessageModel(
      messageId: messageId,
      senderId: 'system',
      message: message,
      type: MessageType.system,
      readBy: [],
      status: MessageStatus.sent,
    );

    await _messagesRef(chatId).doc(messageId).set(msg.toMap());
  }

  Future<void> _updateChatMetadata({
    required String chatId,
    required String senderId,
    required String lastMessage,
    required String lastMessageType,
  }) async {
    final chatDoc = await _chatsRef.doc(chatId).get();
    if (!chatDoc.exists) return;

    final chatData = chatDoc.data() as Map<String, dynamic>;
    final participants = List<String>.from(chatData['participants'] ?? []);

    final Map<String, dynamic> updateData = {
      'lastMessage': lastMessage,
      'lastMessageType': lastMessageType,
      'lastSenderId': senderId,
      'updatedAt': Timestamp.now(),
      'typing.$senderId': false,
    };

    for (final uid in participants) {
      if (uid != senderId) {
        final presenceDoc = await _presenceRef.doc(uid).get();
        final isViewingChat = presenceDoc.exists &&
            (presenceDoc.data() as Map<String, dynamic>?)?['activeChat'] ==
                chatId;

        if (!isViewingChat) {
          updateData['unreadCount.$uid'] = FieldValue.increment(1);
        }
      }
    }

    await _chatsRef.doc(chatId).update(updateData);
  }

  // ════════════════════════════════════════════════════════
  // 3. READING MESSAGES
  // ════════════════════════════════════════════════════════

  Stream<List<MessageModel>> streamMessages(
    String chatId, {
    int limit = 50,
  }) {
    return _messagesRef(chatId)
        .orderBy('timestamp', descending: false)
        .limitToLast(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                MessageModel.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  Future<List<MessageModel>> loadOlderMessages(
    String chatId, {
    required DateTime beforeTimestamp,
    int limit = 25,
  }) async {
    try {
      final snapshot = await _messagesRef(chatId)
          .orderBy('timestamp', descending: true)
          .startAfter([Timestamp.fromDate(beforeTimestamp)])
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) =>
              MessageModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList()
          .reversed
          .toList();
    } catch (e) {
      throw Exception('Failed to load older messages: $e');
    }
  }

  // ════════════════════════════════════════════════════════
  // 4. READ RECEIPTS & UNREAD COUNTS
  // ════════════════════════════════════════════════════════

  Future<void> markMessagesAsRead({
    required String chatId,
    required String myUid,
  }) async {
    try {
      final unreadMessages = await _messagesRef(chatId)
          .where('senderId', isNotEqualTo: myUid)
          .get();

      final batch = _db.batch();
      int updatedCount = 0;

      for (final doc in unreadMessages.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final readBy = List<String>.from(data['readBy'] ?? []);

        if (!readBy.contains(myUid)) {
          batch.update(doc.reference, {
            'readBy': FieldValue.arrayUnion([myUid]),
            'status': 'read',
          });
          updatedCount++;
        }
      }

      if (updatedCount > 0) {
        await batch.commit();
      }

      await _chatsRef.doc(chatId).update({
        'unreadCount.$myUid': 0,
      });
    } catch (e) {
      // Silently fail — non-critical
    }
  }

  // ════════════════════════════════════════════════════════
  // 5. TYPING INDICATORS
  // ════════════════════════════════════════════════════════

  Timer? _typingTimer;

  Future<void> setTyping({
    required String chatId,
    required String uid,
    required bool isTyping,
  }) async {
    try {
      _typingTimer?.cancel();

      await _chatsRef.doc(chatId).update({
        'typing.$uid': isTyping,
      });

      if (isTyping) {
        _typingTimer = Timer(const Duration(seconds: 3), () {
          _chatsRef.doc(chatId).update({
            'typing.$uid': false,
          });
        });
      }
    } catch (e) {
      // Non-critical
    }
  }

  Future<void> clearTyping({
    required String chatId,
    required String uid,
  }) async {
    _typingTimer?.cancel();
    try {
      await _chatsRef.doc(chatId).update({
        'typing.$uid': false,
      });
    } catch (e) {
      // Ignore
    }
  }

  // ════════════════════════════════════════════════════════
  // 6. USER PRESENCE
  // ════════════════════════════════════════════════════════

  Future<void> setOnline({
    required String uid,
    String? activeChat,
  }) async {
    try {
      await _presenceRef.doc(uid).set({
        'online': true,
        'lastSeen': Timestamp.now(),
        'activeChat': activeChat,
      }, SetOptions(merge: true));
    } catch (e) {
      // Non-critical
    }
  }

  Future<void> setOffline(String uid) async {
    try {
      await _presenceRef.doc(uid).set({
        'online': false,
        'lastSeen': Timestamp.now(),
        'activeChat': null,
      }, SetOptions(merge: true));
    } catch (e) {
      // Non-critical
    }
  }

  Stream<UserPresence> streamPresence(String uid) {
    return _presenceRef.doc(uid).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return UserPresence.fromMap(
            doc.data() as Map<String, dynamic>, uid);
      }
      return UserPresence(uid: uid);
    });
  }

  void dispose() {
    _typingTimer?.cancel();
  }
}
