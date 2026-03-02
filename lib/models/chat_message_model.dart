import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType { text, image, jobUpdate, system }

enum MessageStatus { sending, sent, delivered, read }

class MessageModel {
  final String messageId;
  final String senderId;
  final String message;
  final MessageType type;
  final String? imageUrl;
  final Map<String, dynamic>? jobUpdate;
  final DateTime timestamp;
  final List<String> readBy;
  final MessageStatus status;

  MessageModel({
    required this.messageId,
    required this.senderId,
    required this.message,
    this.type = MessageType.text,
    this.imageUrl,
    this.jobUpdate,
    DateTime? timestamp,
    this.readBy = const [],
    this.status = MessageStatus.sending,
  }) : timestamp = timestamp ?? DateTime.now();

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      messageId: map['messageId'] ?? '',
      senderId: map['senderId'] ?? '',
      message: map['message'] ?? '',
      type: _parseMessageType(map['type']),
      imageUrl: map['imageUrl'],
      jobUpdate: map['jobUpdate'] != null
          ? Map<String, dynamic>.from(map['jobUpdate'])
          : null,
      timestamp: map['timestamp'] != null
          ? (map['timestamp'] as Timestamp).toDate()
          : DateTime.now(),
      readBy: List<String>.from(map['readBy'] ?? []),
      status: _parseMessageStatus(map['status']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'senderId': senderId,
      'message': message,
      'type': type.name,
      'imageUrl': imageUrl,
      'jobUpdate': jobUpdate,
      'timestamp': Timestamp.fromDate(timestamp),
      'readBy': readBy,
      'status': status.name,
    };
  }

  MessageModel copyWith({
    List<String>? readBy,
    MessageStatus? status,
  }) {
    return MessageModel(
      messageId: messageId,
      senderId: senderId,
      message: message,
      type: type,
      imageUrl: imageUrl,
      jobUpdate: jobUpdate,
      timestamp: timestamp,
      readBy: readBy ?? this.readBy,
      status: status ?? this.status,
    );
  }

  bool isReadBy(String uid) => readBy.contains(uid);
  bool isMine(String currentUid) => senderId == currentUid;

  static MessageType _parseMessageType(String? value) {
    switch (value) {
      case 'image': return MessageType.image;
      case 'jobUpdate': return MessageType.jobUpdate;
      case 'system': return MessageType.system;
      default: return MessageType.text;
    }
  }

  static MessageStatus _parseMessageStatus(String? value) {
    switch (value) {
      case 'sent': return MessageStatus.sent;
      case 'delivered': return MessageStatus.delivered;
      case 'read': return MessageStatus.read;
      default: return MessageStatus.sending;
    }
  }
}
