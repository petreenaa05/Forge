import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String id;
  final String senderId;
  final String text;
  final DateTime timestamp;

  const MessageModel({
    required this.id,
    required this.senderId,
    required this.text,
    required this.timestamp,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map, String id) {
    return MessageModel(
      id: id,
      senderId: map['senderId'] ?? '',
      text: map['text'] ?? '',
      timestamp: map['timestamp'] is Timestamp
          ? (map['timestamp'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}

class ConversationModel {
  final String id;
  final List<String> participants;
  final Map<String, String> participantNames; // uid -> name
  final String lastMessage;
  final DateTime updatedAt;
  final String jobId;

  const ConversationModel({
    required this.id,
    required this.participants,
    required this.participantNames,
    required this.lastMessage,
    required this.updatedAt,
    required this.jobId,
  });

  factory ConversationModel.fromMap(Map<String, dynamic> map, String id) {
    return ConversationModel(
      id: id,
      participants: List<String>.from(map['participants'] ?? []),
      participantNames: Map<String, String>.from(map['participantNames'] ?? {}),
      lastMessage: map['lastMessage'] ?? '',
      updatedAt: map['updatedAt'] is Timestamp
          ? (map['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
      jobId: map['jobId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'participants': participants,
      'participantNames': participantNames,
      'lastMessage': lastMessage,
      'updatedAt': Timestamp.fromDate(updatedAt),
      'jobId': jobId,
    };
  }
}
