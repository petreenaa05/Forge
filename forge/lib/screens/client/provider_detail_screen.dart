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
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // -- Header --
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: const Color(0xFFA82323),
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: const Color(0xFFA82323),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 24),
                      // Avatar with verified badge
                      Stack(
                        children: [
                          _avatar(provider, 48, textSize: 34, bgColor: Colors.white24),
                          if (provider.verified)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2E7D32),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: const Icon(
                                  Icons.check,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        provider.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (provider.location.isNotEmpty)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.location_on_outlined, 
                              color: Colors.white70, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              provider.location,
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 14),
                            ),
                          ],
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
                          .map((s) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFDF2F2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color(0xFFA82323).withOpacity(0.2),
                                  ),
                                ),
                                child: Text(
                                  s,
                                  style: const TextStyle(
                                    color: Color(0xFFA82323),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
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
              child: Row(
                children: [
                  // Message button
                  Expanded(
                    flex: 1,
                    child: SizedBox(
                      height: 54,
                      child: FloatingActionButton.extended(
                        heroTag: 'message',
                        onPressed: () => Navigator.of(context).pushNamed(
                          '/chat',
                          arguments: {'receiverId': provider.uid},
                        ),
                        backgroundColor: Colors.white,
                        label: const Row(
                          children: [
                            Icon(Icons.chat_bubble_outline_rounded, 
                              color: Color(0xFFA82323), size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Message',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFA82323),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Book button
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 54,
                      child: FloatingActionButton.extended(
                        heroTag: 'book',
                        onPressed: () => _showBookingSheet(provider),
                        backgroundColor: const Color(0xFFA82323),
                        label: const Row(
                          children: [
                            Icon(Icons.calendar_month_rounded, 
                              color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Book Service',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
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
    TimeOfDay selectedTime = const TimeOfDay(hour: 10, minute: 0);
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                      // Handle bar
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0E0E0),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Title
                      const Row(
                        children: [
                          Icon(Icons.calendar_month_rounded, 
                            color: Color(0xFFA82323), size: 24),
                          SizedBox(width: 12),
                          Text(
                            'Book Service',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Book with ${provider.name}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black.withValues(alpha: 0.5),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Service Title
                      TextFormField(
                        controller: titleCtrl,
                        style: const TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          labelText: 'Service Title',
                          labelStyle: TextStyle(color: Colors.black.withValues(alpha: 0.5)),
                          hintText: 'e.g., Fix kitchen plumbing',
                          hintStyle: TextStyle(color: Colors.black.withValues(alpha: 0.3)),
                          filled: true,
                          fillColor: const Color(0xFFF8F8F8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFA82323), width: 1.5),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Please enter a service title'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // Description
                      TextFormField(
                        controller: descCtrl,
                        maxLines: 3,
                        style: const TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          labelText: 'Description (optional)',
                          labelStyle: TextStyle(color: Colors.black.withValues(alpha: 0.5)),
                          hintText: 'Describe the work needed...',
                          hintStyle: TextStyle(color: Colors.black.withValues(alpha: 0.3)),
                          filled: true,
                          fillColor: const Color(0xFFF8F8F8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFA82323), width: 1.5),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Date and Time row
                      Row(
                        children: [
                          // Date picker
                          Expanded(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: ctx,
                                  initialDate: selectedDate,
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now().add(const Duration(days: 90)),
                                  builder: (context, child) {
                                    return Theme(
                                      data: Theme.of(context).copyWith(
                                        colorScheme: const ColorScheme.light(
                                          primary: Color(0xFFA82323),
                                          onPrimary: Colors.white,
                                          surface: Colors.white,
                                          onSurface: Colors.black,
                                        ),
                                      ),
                                      child: child!,
                                    );
                                  },
                                );
                                if (picked != null) {
                                  setSheetState(() => selectedDate = picked);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8F8F8),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFE0E0E0)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.calendar_today_rounded,
                                      color: Color(0xFFA82323), size: 20),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Date',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Color(0xFF808080),
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.chevron_right,
                                      color: Color(0xFF808080), size: 18),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          
                          // Time picker
                          Expanded(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () async {
                                final picked = await showTimePicker(
                                  context: ctx,
                                  initialTime: selectedTime,
                                  builder: (context, child) {
                                    return Theme(
                                      data: Theme.of(context).copyWith(
                                        colorScheme: const ColorScheme.light(
                                          primary: Color(0xFFA82323),
                                          onPrimary: Colors.white,
                                          surface: Colors.white,
                                          onSurface: Colors.black,
                                        ),
                                      ),
                                      child: child!,
                                    );
                                  },
                                );
                                if (picked != null) {
                                  setSheetState(() => selectedTime = picked);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8F8F8),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFE0E0E0)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.access_time_rounded,
                                      color: Color(0xFFA82323), size: 20),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Time',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Color(0xFF808080),
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            selectedTime.format(ctx),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.chevron_right,
                                      color: Color(0xFF808080), size: 18),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // Book button
                      SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (!formKey.currentState!.validate()) return;

                            final uid = context.read<AuthProvider>().uid ?? '';
                            final clientName = context.read<UserProvider>().user?.name ?? '';

                            // Combine date and time
                            final scheduledDateTime = DateTime(
                              selectedDate.year,
                              selectedDate.month,
                              selectedDate.day,
                              selectedTime.hour,
                              selectedTime.minute,
                            );

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
                              scheduledDate: scheduledDateTime,
                              createdAt: DateTime.now(),
                            );

                            await context.read<JobProvider>().createJob(job);

                            if (ctx.mounted) Navigator.pop(ctx);

                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      const Icon(Icons.check_circle_rounded,
                                        color: Colors.white, size: 20),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          'Service booked for ${selectedDate.day}/${selectedDate.month} at ${selectedTime.format(context)}',
                                          style: const TextStyle(fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    ],
                                  ),
                                  backgroundColor: const Color(0xFF2E7D32),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  margin: const EdgeInsets.all(16),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFA82323),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_rounded, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Confirm Booking',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
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
      backgroundColor: bgColor ?? const Color(0xFFA82323),
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
