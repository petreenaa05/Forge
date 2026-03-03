import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:forge/models/job_model.dart';
import 'package:forge/models/review_model.dart';
import 'package:forge/services/firestore_service.dart';

class JobProvider extends ChangeNotifier {
  final FirestoreService _db = FirestoreService();
  List<JobModel> _providerJobs = [];
  List<JobModel> _clientJobs = [];
  bool _isLoading = false;
  StreamSubscription<List<JobModel>>? _providerSub;
  StreamSubscription<List<JobModel>>? _clientSub;

  List<JobModel> get providerJobs => _providerJobs;
  List<JobModel> get clientJobs => _clientJobs;
  bool get isLoading => _isLoading;

  List<JobModel> get incomingJobs =>
      _providerJobs.where((j) => j.status == 'requested').toList();

  List<JobModel> get activeJobs =>
      _providerJobs.where((j) => j.status == 'confirmed').toList();

  List<JobModel> get completedJobs =>
      _providerJobs.where((j) => j.status == 'completed').toList();

  Future<String> createJob(JobModel job) => _db.createJob(job);

  void listenToProviderJobs(String providerId) {
    _providerSub?.cancel();
    _providerSub = _db.getJobsByProvider(providerId).listen((jobs) {
      _providerJobs = jobs;
      notifyListeners();
    });
  }

  void listenToClientJobs(String clientId) {
    _clientSub?.cancel();
    _clientSub = _db.getJobsByClient(clientId).listen((jobs) {
      _clientJobs = jobs;
      notifyListeners();
    });
  }

  Future<void> updateJobStatus(String jobId, String status) async {
    _isLoading = true;
    notifyListeners();
    await _db.updateJobStatus(jobId, status);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> submitReview(ReviewModel review, int currentTotal) async {
    _isLoading = true;
    notifyListeners();
    await _db.createReview(review);
    await _db.updateProviderRating(
      review.providerId,
      review.rating,
      currentTotal,
    );
    _isLoading = false;
    notifyListeners();
  }

  void cancelSubscriptions() {
    _providerSub?.cancel();
    _clientSub?.cancel();
    _providerJobs = [];
    _clientJobs = [];
    notifyListeners();
  }

  @override
  void dispose() {
    _providerSub?.cancel();
    _clientSub?.cancel();
    super.dispose();
  }
}
