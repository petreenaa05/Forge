import 'package:cloud_firestore/cloud_firestore.dart';

class JobModel {
  final String id;
  final String clientId;
  final String clientName;
  final String providerId;
  final String category;
  final String title;
  final String description;
  final String status; // requested | confirmed | completed | rejected
  final DateTime scheduledDate;
  final DateTime createdAt;

  const JobModel({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.providerId,
    required this.category,
    required this.title,
    required this.description,
    required this.status,
    required this.scheduledDate,
    required this.createdAt,
  });

  factory JobModel.fromMap(Map<String, dynamic> map, String id) {
    return JobModel(
      id: id,
      clientId: map['clientId'] ?? '',
      clientName: map['clientName'] ?? '',
      providerId: map['providerId'] ?? '',
      category: map['category'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      status: map['status'] ?? 'requested',
      scheduledDate: map['scheduledDate'] is Timestamp
          ? (map['scheduledDate'] as Timestamp).toDate()
          : DateTime.now(),
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'clientId': clientId,
      'clientName': clientName,
      'providerId': providerId,
      'category': category,
      'title': title,
      'description': description,
      'status': status,
      'scheduledDate': Timestamp.fromDate(scheduledDate),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
