import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:forge/models/user_model.dart';
import 'package:forge/models/job_model.dart';
import 'package:forge/models/review_model.dart';
import 'package:forge/providers/auth_provider.dart';
import 'package:forge/providers/user_provider.dart';
import 'package:forge/providers/job_provider.dart';
import 'package:forge/services/firestore_service.dart';
import 'package:forge/core/theme/app_theme.dart';
import 'package:forge/widgets/rating_widget.dart';

/// Shows a freelancer's full profile: bio, skills, experience, reviews,
/// completed jobs, availability, and a "Book Service" button.
///
/// Accepts route arguments:
///   - `providerId`  → loads a single freelancer
///   - `category`    → lists all freelancers in a category
class ProviderDetailScreen extends StatefulWidget {
  const ProviderDetailScreen({super.key});

  @override
  State<ProviderDetailScreen> createState() => _ProviderDetailScreenState();
}

class _ProviderDetailScreenState extends State<ProviderDetailScreen> {
  final FirestoreService _db = FirestoreService();

  UserModel? _provider;
  List<UserModel> _categoryProviders = [];
  bool _loading = true;
  String? _category;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args == null) return;

    if (args.containsKey('providerId')) {
      _loadSingleProvider(args['providerId'] as String);
    } else if (args.containsKey('category')) {
      _category = args['category'] as String;
      _loadCategoryProviders(_category!);
    }
  }

  Future<void> _loadSingleProvider(String uid) async {
    try {
      final u = await _db.getUser(uid);
      if (mounted) setState(() { _provider = u; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadCategoryProviders(String category) async {
    try {
      final list = await _db.getFreelancersByCategory(category);
      if (mounted) setState(() { _categoryProviders = list; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text(_category ?? 'Profile')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Category listing mode
    if (_category != null) {
      return _buildCategoryList();
    }

    // Single provider mode
    if (_provider == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: Text('Provider not found')),
      );
    }

    return _buildProviderProfile(_provider!);
  }

  // ── Category list ───────────────────────────────────────────────────────
  Widget _buildCategoryList() {
    return Scaffold(
      appBar: AppBar(title: Text(_category!)),
      backgroundColor: AppTheme.background,
      body: _categoryProviders.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.search_off, size: 56,
                      color: AppTheme.textMedium.withOpacity(0.4)),
                  const SizedBox(height: 12),
                  Text('No professionals found in $_category',
                      style: const TextStyle(color: AppTheme.textMedium)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _categoryProviders.length,
              itemBuilder: (_, i) {
                final f = _categoryProviders[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.of(context).pushNamed(
                        '/provider-detail',
                        arguments: {'providerId': f.uid},
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          _avatar(f, 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(f.name,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15)),
                                    if (f.verified) ...[
                                      const SizedBox(width: 4),
                                      const Icon(Icons.check_circle,
                                          color: AppTheme.verified, size: 16),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 4),
                                RatingWidget(
                                    rating: f.rating,
                                    size: 14,
                                    showNumber: true),
                                const SizedBox(height: 4),
                                Text(
                                  '${f.experience} yrs • ${f.completedJobs} jobs',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textMedium),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: f.available
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFF9CA3AF),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.chevron_right,
                              color: AppTheme.textMedium),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  // ── Single provider profile ─────────────────────────────────────────────
  Widget _buildProviderProfile(UserModel provider) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          // -- Header --
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppTheme.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppTheme.primary, Color(0xFF4C1D95)],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 24),
                      _avatar(provider, 44, textSize: 32, bgColor: Colors.white24),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            provider.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (provider.verified) ...[
                            const SizedBox(width: 6),
                            const Icon(Icons.check_circle,
                                color: AppTheme.verified, size: 20),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      if (provider.location.isNotEmpty)
                        Text(
                          '📍 ${provider.location}',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 14),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // -- Body --
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _statCard('⭐', provider.rating.toStringAsFixed(1),
                          'Rating'),
                      _statCard('📊', '${provider.completedJobs}',
                          'Jobs Done'),
                      _statCard('🗓️', '${provider.experience} yrs',
                          'Experience'),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Availability
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: provider.available
                          ? const Color(0xFFD1FAE5)
                          : const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          provider.available
                              ? Icons.check_circle
                              : Icons.schedule,
                          size: 18,
                          color: provider.available
                              ? const Color(0xFF059669)
                              : const Color(0xFFD97706),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          provider.available
                              ? 'Available for work now'
                              : 'Currently unavailable',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: provider.available
                                ? const Color(0xFF059669)
                                : const Color(0xFFD97706),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Bio
                  if (provider.bio.isNotEmpty) ...[
                    _sectionTitle('About'),
                    const SizedBox(height: 6),
                    Text(
                      provider.bio,
                      style: const TextStyle(
                          color: AppTheme.textMedium, height: 1.5),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Skills
                  if (provider.skills.isNotEmpty) ...[
                    _sectionTitle('Skills'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: provider.skills
                          .map((s) => Chip(
                                label: Text(s),
                                backgroundColor: const Color(0xFFF3E8FF),
                                labelStyle: const TextStyle(
                                    color: AppTheme.primary, fontSize: 13),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Reviews stream
                  _sectionTitle('Reviews'),
                  const SizedBox(height: 8),
                  _ReviewsList(providerId: provider.uid),

                  const SizedBox(height: 80), // space for FAB
                ],
              ),
            ),
          ),
        ],
      ),

      // ── Book button ─────────────────────────────────────────────────
      floatingActionButton: provider.available
          ? SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              height: 54,
              child: FloatingActionButton.extended(
                onPressed: () => _showBookingSheet(provider),
                backgroundColor: AppTheme.primary,
                label: const Text(
                  'Book Service',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white),
                ),
                icon: const Icon(Icons.calendar_today, color: Colors.white),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // ── Booking bottom sheet ────────────────────────────────────────────────
  void _showBookingSheet(UserModel provider) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Book Service',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark),
                      ),
                      const SizedBox(height: 20),

                      TextFormField(
                        controller: titleCtrl,
                        decoration:
                            const InputDecoration(labelText: 'Service Title'),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Required'
                            : null,
                      ),
                      const SizedBox(height: 14),

                      TextFormField(
                        controller: descCtrl,
                        maxLines: 3,
                        decoration:
                            const InputDecoration(labelText: 'Description'),
                      ),
                      const SizedBox(height: 14),

                      // Date picker
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.calendar_today,
                            color: AppTheme.primary),
                        title: Text(
                          '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: const Text('Preferred date'),
                        trailing: TextButton(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: ctx,
                              initialDate: selectedDate,
                              firstDate: DateTime.now(),
                              lastDate:
                                  DateTime.now().add(const Duration(days: 90)),
                            );
                            if (picked != null) {
                              setSheetState(() => selectedDate = picked);
                            }
                          },
                          child: const Text('Change'),
                        ),
                      ),
                      const SizedBox(height: 20),

                      ElevatedButton(
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) return;

                          final uid =
                              context.read<AuthProvider>().uid ?? '';
                          final clientName =
                              context.read<UserProvider>().user?.name ?? '';

                          final job = JobModel(
                            id: '',
                            clientId: uid,
                            clientName: clientName,
                            providerId: provider.uid,
                            category: provider.skills.isNotEmpty
                                ? provider.skills.first
                                : 'General',
                            title: titleCtrl.text.trim(),
                            description: descCtrl.text.trim(),
                            status: 'requested',
                            scheduledDate: selectedDate,
                            createdAt: DateTime.now(),
                          );

                          await context.read<JobProvider>().createJob(job);

                          if (ctx.mounted) Navigator.pop(ctx);

                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Service requested! Waiting for confirmation.'),
                                backgroundColor: AppTheme.verified,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                        child: const Text('Request Service'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────
  Widget _avatar(UserModel u, double radius,
      {double textSize = 22, Color? bgColor}) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: bgColor ?? AppTheme.primary,
      backgroundImage:
          u.photoUrl != null ? NetworkImage(u.photoUrl!) : null,
      child: u.photoUrl == null
          ? Text(
              u.name.isNotEmpty ? u.name[0].toUpperCase() : '?',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: textSize,
                  fontWeight: FontWeight.bold),
            )
          : null,
    );
  }

  Widget _statCard(String emoji, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppTheme.textDark)),
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: AppTheme.textMedium)),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: AppTheme.textDark),
    );
  }
}

// ---------------------------------------------------------------------------
// Reviews list (stream-based)
// ---------------------------------------------------------------------------
class _ReviewsList extends StatelessWidget {
  final String providerId;
  const _ReviewsList({required this.providerId});

  @override
  Widget build(BuildContext context) {
    final db = FirestoreService();
    return StreamBuilder<List<ReviewModel>>(
      stream: db.getReviewsByProvider(providerId),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final reviews = snap.data ?? [];
        if (reviews.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text('No reviews yet',
                style: TextStyle(color: AppTheme.textMedium)),
          );
        }

        return Column(
          children: reviews
              .map(
                (r) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(r.clientName,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
                          const Spacer(),
                          RatingWidget(
                              rating: r.rating, size: 14, showNumber: false),
                        ],
                      ),
                      if (r.comment.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(r.comment,
                            style: const TextStyle(
                                color: AppTheme.textMedium, height: 1.4)),
                      ],
                    ],
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}
