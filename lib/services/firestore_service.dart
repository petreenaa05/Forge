import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:forge/models/user_model.dart';
import 'package:forge/models/job_model.dart';
import 'package:forge/models/review_model.dart';
import 'package:forge/models/message_model.dart';
import 'package:forge/core/constants/app_constants.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ---------------------------------------------------------------------------
  // USERS
  // ---------------------------------------------------------------------------

  Future<void> createUser(UserModel user) async {
    try {
      await _db
          .collection(AppCollections.users)
          .doc(user.uid)
          .set(user.toMap());
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  Future<UserModel?> getUser(String uid) async {
    try {
      final doc =
          await _db.collection(AppCollections.users).doc(uid).get();
      if (!doc.exists || doc.data() == null) return null;
      return UserModel.fromMap(doc.data()!, doc.id);
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    try {
      await _db.collection(AppCollections.users).doc(uid).update(data);
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  Future<List<UserModel>> getFreelancersByCategory(String category) async {
    try {
      final snapshot = await _db
          .collection(AppCollections.users)
          .where('role', isEqualTo: UserRole.freelancer)
          .where('skills', arrayContains: category)
          .orderBy('rating', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get freelancers by category: $e');
    }
  }

  Future<List<UserModel>> getTopRatedFreelancers() async {
    try {
      final snapshot = await _db
          .collection(AppCollections.users)
          .where('role', isEqualTo: UserRole.freelancer)
          .orderBy('rating', descending: true)
          .limit(10)
          .get();
      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get top rated freelancers: $e');
    }
  }

  Future<List<UserModel>> getAvailableFreelancers() async {
    try {
      final snapshot = await _db
          .collection(AppCollections.users)
          .where('role', isEqualTo: UserRole.freelancer)
          .where('available', isEqualTo: true)
          .orderBy('rating', descending: true)
          .limit(10)
          .get();
      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get available freelancers: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // JOBS
  // ---------------------------------------------------------------------------

  Future<String> createJob(JobModel job) async {
    try {
      final docRef = await _db
          .collection(AppCollections.jobs)
          .add(job.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create job: $e');
    }
  }

  Stream<List<JobModel>> getJobsByProvider(String providerId) {
    return _db
        .collection(AppCollections.jobs)
        .where('providerId', isEqualTo: providerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => JobModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Stream<List<JobModel>> getJobsByClient(String clientId) {
    return _db
        .collection(AppCollections.jobs)
        .where('clientId', isEqualTo: clientId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => JobModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> updateJobStatus(String jobId, String status) async {
    try {
      await _db.runTransaction((transaction) async {
        final jobRef =
            _db.collection(AppCollections.jobs).doc(jobId);
        final jobSnap = await transaction.get(jobRef);

        if (!jobSnap.exists) {
          throw Exception('Job not found: $jobId');
        }

        transaction.update(jobRef, {'status': status});

        if (status == JobStatus.completed) {
          final providerId =
              (jobSnap.data() as Map<String, dynamic>)['providerId'] as String?;
          if (providerId != null && providerId.isNotEmpty) {
            final providerRef =
                _db.collection(AppCollections.users).doc(providerId);
            transaction.update(providerRef, {
              'completedJobs': FieldValue.increment(1),
            });
          }
        }
      });
    } catch (e) {
      throw Exception('Failed to update job status: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // REVIEWS
  // ---------------------------------------------------------------------------

  Future<void> createReview(ReviewModel review) async {
    try {
      await _db.collection(AppCollections.reviews).add(review.toMap());
    } catch (e) {
      throw Exception('Failed to create review: $e');
    }
  }

  Stream<List<ReviewModel>> getReviewsByProvider(String providerId) {
    return _db
        .collection(AppCollections.reviews)
        .where('providerId', isEqualTo: providerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ReviewModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> updateProviderRating(
    String providerId,
    double newRating,
    int currentTotal,
  ) async {
    try {
      final providerRef =
          _db.collection(AppCollections.users).doc(providerId);

      await _db.runTransaction((transaction) async {
        final providerSnap = await transaction.get(providerRef);
        if (!providerSnap.exists) {
          throw Exception('Provider not found: $providerId');
        }

        final data = providerSnap.data() as Map<String, dynamic>;
        final oldRating = (data['rating'] ?? 0.0).toDouble();
        final oldTotal = (data['totalRatings'] ?? 0) as int;

        // Use the live totalRatings from Firestore to avoid stale reads,
        // but fall back to currentTotal if the field is missing.
        final effectiveTotal = oldTotal > 0 ? oldTotal : currentTotal;
        final newAvg =
            ((oldRating * effectiveTotal) + newRating) / (effectiveTotal + 1);

        transaction.update(providerRef, {
          'rating': newAvg,
          'totalRatings': FieldValue.increment(1),
        });
      });
    } catch (e) {
      throw Exception('Failed to update provider rating: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // CHAT
  // ---------------------------------------------------------------------------

  Future<String> getOrCreateConversation(
    String jobId,
    List<String> participants,
    Map<String, String> participantNames,
  ) async {
    try {
      // Check whether a conversation for this job already exists.
      final existing = await _db
          .collection(AppCollections.chats)
          .where('jobId', isEqualTo: jobId)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        return existing.docs.first.id;
      }

      // Create a new conversation document.
      final now = DateTime.now();
      final newConversation = ConversationModel(
        id: '',
        participants: participants,
        participantNames: participantNames,
        lastMessage: '',
        updatedAt: now,
        jobId: jobId,
      );

      final docRef = await _db
          .collection(AppCollections.chats)
          .add(newConversation.toMap());

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to get or create conversation: $e');
    }
  }

  Future<void> sendMessage(String chatId, MessageModel message) async {
    try {
      final chatRef = _db.collection(AppCollections.chats).doc(chatId);
      final messagesRef =
          chatRef.collection(AppCollections.messages);

      // Use a batch so both writes succeed or fail together.
      final batch = _db.batch();

      final msgDocRef = messagesRef.doc();
      batch.set(msgDocRef, message.toMap());

      batch.update(chatRef, {
        'lastMessage': message.text,
        'updatedAt': Timestamp.fromDate(message.timestamp),
      });

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  Stream<List<MessageModel>> getMessages(String chatId) {
    return _db
        .collection(AppCollections.chats)
        .doc(chatId)
        .collection(AppCollections.messages)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MessageModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Stream<List<ConversationModel>> getConversations(String userId) {
    return _db
        .collection(AppCollections.chats)
        .where('participants', arrayContains: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ConversationModel.fromMap(doc.data(), doc.id))
            .toList());
  }
}
