import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String chatId;
  final List<String> participants;
  final Map<String, String> participantNames;
  final Map<String, String> participantImages;
  final String lastMessage;
  final String lastMessageType;
  final String lastSenderId;
  final DateTime updatedAt;
  final DateTime createdAt;
  final Map<String, int> unreadCount;
  final Map<String, bool> typing;
  final String? jobId;

  ChatModel({
    required this.chatId,
    required this.participants,
    this.participantNames = const {},
    this.participantImages = const {},
    this.lastMessage = '',
    this.lastMessageType = 'text',
    this.lastSenderId = '',
    DateTime? updatedAt,
    DateTime? createdAt,
    this.unreadCount = const {},
    this.typing = const {},
    this.jobId,
  })  : updatedAt = updatedAt ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now();

  factory ChatModel.fromMap(Map<String, dynamic> map) {
    return ChatModel(
      chatId: map['chatId'] ?? '',
      participants: List<String>.from(map['participants'] ?? []),
      participantNames:
          Map<String, String>.from(map['participantNames'] ?? {}),
      participantImages:
          Map<String, String>.from(map['participantImages'] ?? {}),
      lastMessage: map['lastMessage'] ?? '',
      lastMessageType: map['lastMessageType'] ?? 'text',
      lastSenderId: map['lastSenderId'] ?? '',
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      unreadCount: Map<String, int>.from(map['unreadCount'] ?? {}),
      typing: Map<String, bool>.from(map['typing'] ?? {}),
      jobId: map['jobId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'chatId': chatId,
      'participants': participants,
      'participantNames': participantNames,
      'participantImages': participantImages,
      'lastMessage': lastMessage,
      'lastMessageType': lastMessageType,
      'lastSenderId': lastSenderId,
      'updatedAt': Timestamp.fromDate(updatedAt),
      'createdAt': Timestamp.fromDate(createdAt),
      'unreadCount': unreadCount,
      'typing': typing,
      'jobId': jobId,
    };
  }

  String getOtherUid(String myUid) =>
      participants.firstWhere((uid) => uid != myUid, orElse: () => '');

  String getOtherName(String myUid) {
    final otherUid = getOtherUid(myUid);
    return participantNames[otherUid] ?? 'Unknown';
  }

  String getOtherImage(String myUid) {
    final otherUid = getOtherUid(myUid);
    return participantImages[otherUid] ?? '';
  }

  int getUnreadCount(String uid) => unreadCount[uid] ?? 0;

  bool isOtherTyping(String myUid) {
    final otherUid = getOtherUid(myUid);
    return typing[otherUid] ?? false;
  }

  String get lastMessagePreview {
    switch (lastMessageType) {
      case 'image':
        return '📷 Photo';
      case 'job_update':
        return '📋 Job Update';
      case 'system':
        return '🔔 $lastMessage';
      default:
        return lastMessage;
    }
  }
}

class UserPresence {
  final String uid;
  final bool online;
  final DateTime lastSeen;
  final String? activeChat;

  UserPresence({
    required this.uid,
    this.online = false,
    DateTime? lastSeen,
    this.activeChat,
  }) : lastSeen = lastSeen ?? DateTime.now();

  factory UserPresence.fromMap(Map<String, dynamic> map, String uid) {
    return UserPresence(
      uid: uid,
      online: map['online'] ?? false,
      lastSeen: map['lastSeen'] != null
          ? (map['lastSeen'] as Timestamp).toDate()
          : DateTime.now(),
      activeChat: map['activeChat'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'online': online,
      'lastSeen': Timestamp.fromDate(lastSeen),
      'activeChat': activeChat,
    };
  }
}
