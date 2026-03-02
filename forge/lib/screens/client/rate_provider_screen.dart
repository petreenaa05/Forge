import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:forge/models/review_model.dart';
import 'package:forge/providers/auth_provider.dart';
import 'package:forge/providers/user_provider.dart';
import 'package:forge/providers/job_provider.dart';
import 'package:forge/core/theme/app_theme.dart';

/// Star rating + comment screen shown after a client marks a job as completed.
///
/// Expects route arguments: `{ 'jobId': String, 'providerId': String }`
class RateProviderScreen extends StatefulWidget {
  const RateProviderScreen({super.key});

  @override
  State<RateProviderScreen> createState() => _RateProviderScreenState();
}

class _RateProviderScreenState extends State<RateProviderScreen> {
  double _rating = 5.0;
  final _commentCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit(String jobId, String providerId) async {
    setState(() => _submitting = true);

    final uid = context.read<AuthProvider>().uid ?? '';
    final clientName = context.read<UserProvider>().user?.name ?? '';

    final review = ReviewModel(
      id: '',
      jobId: jobId,
      providerId: providerId,
      clientId: uid,
      clientName: clientName,
      rating: _rating,
      comment: _commentCtrl.text.trim(),
      createdAt: DateTime.now(),
    );

    final userProvider = context.read<UserProvider>();
    final currentTotal = userProvider.user?.totalRatings ?? 0;

    await context.read<JobProvider>().submitReview(review, currentTotal);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Thank you for your review!'),
        backgroundColor: AppTheme.verified,
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final jobId = args?['jobId'] as String? ?? '';
    final providerId = args?['providerId'] as String? ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Rate Service'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Illustration
              Center(
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Text('⭐', style: TextStyle(fontSize: 48)),
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'How was the service?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your rating helps build the professional\'s reputation.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textMedium, fontSize: 14),
              ),
              const SizedBox(height: 32),

              // Stars
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  final starValue = i + 1.0;
                  return GestureDetector(
                    onTap: () => setState(() => _rating = starValue),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Icon(
                        _rating >= starValue
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        size: 48,
                        color: _rating >= starValue
                            ? const Color(0xFFFBBF24)
                            : const Color(0xFFD1D5DB),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 8),
              Text(
                _ratingLabel(_rating),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(height: 28),

              // Comment
              TextFormField(
                controller: _commentCtrl,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'Write a review (optional)…',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 32),

              // Submit
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed:
                      _submitting ? null : () => _submit(jobId, providerId),
                  child: _submitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text('Submit Review'),
                ),
              ),

              const SizedBox(height: 16),

              // Skip
              Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Skip',
                    style: TextStyle(color: AppTheme.textMedium),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _ratingLabel(double rating) {
    if (rating >= 5) return 'Excellent! 🌟';
    if (rating >= 4) return 'Great! 😊';
    if (rating >= 3) return 'Good 👍';
    if (rating >= 2) return 'Fair 😐';
    return 'Poor 😞';
  }
}
