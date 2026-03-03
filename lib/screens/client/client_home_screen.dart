import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:forge/models/user_model.dart';
import 'package:forge/models/job_model.dart';
import 'package:forge/providers/auth_provider.dart';
import 'package:forge/providers/user_provider.dart';
import 'package:forge/providers/job_provider.dart';
import 'package:forge/providers/chat_provider.dart';
import 'package:forge/services/firestore_service.dart';
import 'package:forge/core/constants/app_constants.dart';
import 'package:intl/intl.dart';

// =============================================================================
// Design tokens — MAROON #A82323 + BLACK #000000 + WHITE #FFFFFF
// Plus: Green for verified, Yellow for ratings
// =============================================================================

class _C {
  static const Color maroon      = Color(0xFFA82323);
  static const Color maroonDark  = Color(0xFF7A1818); // pressed
  static const Color maroonLight = Color(0xFFFDF2F2); // subtle bg
  static const Color white       = Color(0xFFFFFFFF);
  static const Color black       = Color(0xFF000000);
  static const Color black80     = Color(0xCC000000); // 80% — titles
  static const Color black60     = Color(0x99000000); // 60% — body text
  static const Color black50     = Color(0x80000000); // 50% — subtext
  static const Color black30     = Color(0x4D000000); // 30% — hint text
  static const Color black10     = Color(0x1A000000); // 10% — dividers
  static const Color border      = Color(0xFFE8E8E8); // neutral border
  static const Color borderLight = Color(0xFFF2F2F2); // subtle border
  // Accent colors
  static const Color green       = Color(0xFF2E7D32); // verified tick
  static const Color yellow      = Color(0xFFFFC107); // rating star
  static const Color yellowDark  = Color(0xFFFFB300); // star fill
}

// =============================================================================
// Sample Freelancers Data (Mock)
// =============================================================================

final List<UserModel> _kSampleFreelancers = [
  UserModel(
    uid: 'sample_1',
    name: 'Priya Sharma',
    phone: '+91 98765 43210',
    role: 'freelancer',
    rating: 4.9,
    totalRatings: 127,
    verified: true,
    available: true,
    skills: ['Electrician', 'Home Automation Technician'],
    location: 'Mumbai, Maharashtra',
    bio: 'Certified electrical engineer with 8+ years of experience in residential and commercial wiring.',
    experience: 8,
    photoUrl: null,
    completedJobs: 234,
  ),
  UserModel(
    uid: 'sample_2',
    name: 'Anjali Verma',
    phone: '+91 87654 32109',
    role: 'freelancer',
    rating: 4.8,
    totalRatings: 89,
    verified: true,
    available: true,
    skills: ['Plumber', 'AC Technician'],
    location: 'Delhi, NCR',
    bio: 'Expert plumber specializing in modern bathroom fittings and AC installation.',
    experience: 6,
    photoUrl: null,
    completedJobs: 156,
  ),
  UserModel(
    uid: 'sample_3',
    name: 'Kavitha Reddy',
    phone: '+91 76543 21098',
    role: 'freelancer',
    rating: 4.7,
    totalRatings: 156,
    verified: true,
    available: false,
    skills: ['Carpenter', 'Civil Engineer'],
    location: 'Bangalore, Karnataka',
    bio: 'Civil engineer turned carpenter. Custom furniture and home renovations.',
    experience: 10,
    photoUrl: null,
    completedJobs: 312,
  ),
  UserModel(
    uid: 'sample_4',
    name: 'Meera Patel',
    phone: '+91 65432 10987',
    role: 'freelancer',
    rating: 4.6,
    totalRatings: 67,
    verified: false,
    available: true,
    skills: ['Gym Trainer', 'Bike Repair Specialist'],
    location: 'Ahmedabad, Gujarat',
    bio: 'Certified fitness trainer and passionate bike mechanic.',
    experience: 4,
    photoUrl: null,
    completedJobs: 89,
  ),
  UserModel(
    uid: 'sample_5',
    name: 'Sunita Rao',
    phone: '+91 54321 09876',
    role: 'freelancer',
    rating: 4.9,
    totalRatings: 203,
    verified: true,
    available: true,
    skills: ['Car Mechanic', 'Auto Body Repair Expert'],
    location: 'Chennai, Tamil Nadu',
    bio: 'Award-winning auto repair specialist. All car brands welcome.',
    experience: 12,
    photoUrl: null,
    completedJobs: 456,
  ),
];

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  final FirestoreService _db = FirestoreService();

  List<UserModel> _topRated = [];
  List<Map<String, dynamic>> _notifications = [];
  bool _loadingTop = true;

  @override
  void initState() {
    super.initState();
    // Defer data loading so providers don't notify during the first build frame
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    final uid = context.read<AuthProvider>().uid;
    if (uid != null) {
      context.read<UserProvider>().loadUser(uid);
      context.read<JobProvider>().listenToClientJobs(uid);
      context.read<ChatProvider>().startListening(uid);
    }

    try {
      final top = await _db.getTopRatedFreelancers();
      // Use sample data if no real data exists
      if (mounted) {
        setState(() {
          _topRated = top.isEmpty ? _kSampleFreelancers : top;
          _loadingTop = false;
        });
      }
    } catch (_) {
      // Fallback to sample data on error
      if (mounted) {
        setState(() {
          _topRated = _kSampleFreelancers;
          _loadingTop = false;
        });
      }
    }
    
    // Sample notifications
    _notifications = [
      {'title': 'New Electrician Available', 'skill': 'Electrician', 'time': DateTime.now().subtract(const Duration(minutes: 30))},
      {'title': 'Priya Sharma is now online', 'skill': 'Home Automation', 'time': DateTime.now().subtract(const Duration(hours: 1))},
      {'title': 'New Plumber in your area', 'skill': 'Plumber', 'time': DateTime.now().subtract(const Duration(hours: 2))},
    ];
  }

  Future<void> _switchToFreelancer() async {
    final uid = context.read<AuthProvider>().uid;
    if (uid == null) return;

    final userProvider = context.read<UserProvider>();
    context.read<JobProvider>().cancelSubscriptions();
    await userProvider.switchRole(uid);

    if (!mounted) return;

    // If name is empty, go to setup
    if (userProvider.user?.name.isEmpty ?? true) {
      Navigator.of(context).pushReplacementNamed('/provider-setup');
    } else {
      Navigator.of(context).pushReplacementNamed('/provider-home');
    }
  }

  Future<void> _signOut() async {
    context.read<JobProvider>().cancelSubscriptions();
    await context.read<AuthProvider>().signOut();
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/login');
  }

  void _openCategory(String category) {
    Navigator.of(context).pushNamed(
      '/provider-detail',
      arguments: {'category': category},
    );
  }

  void _openProfile(UserModel freelancer) {
    Navigator.of(context).pushNamed(
      '/provider-detail',
      arguments: {'providerId': freelancer.uid},
    );
  }

  void _showCategorySelector() {
    // Icon mapping for different skill categories
    IconData _getSkillIcon(String skill) {
      final s = skill.toLowerCase();
      if (s.contains('electric')) return Icons.electrical_services_rounded;
      if (s.contains('plumb')) return Icons.plumbing_rounded;
      if (s.contains('ac') || s.contains('repair')) return Icons.ac_unit_rounded;
      if (s.contains('carpenter') || s.contains('civil')) return Icons.carpenter_rounded;
      if (s.contains('car') || s.contains('mechanic')) return Icons.directions_car_rounded;
      if (s.contains('bike')) return Icons.two_wheeler_rounded;
      if (s.contains('gym') || s.contains('trainer')) return Icons.fitness_center_rounded;
      if (s.contains('automation') || s.contains('home')) return Icons.home_rounded;
      if (s.contains('body') || s.contains('auto')) return Icons.build_circle_rounded;
      return Icons.handyman_rounded;
    }
    
    showModalBottomSheet(
      context: context,
      backgroundColor: _C.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: _C.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Icon(Icons.handyman_rounded, color: _C.maroon, size: 24),
                  SizedBox(width: 12),
                  Text(
                    'Select a Service',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: _C.black,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Choose a category to find available professionals',
                style: TextStyle(fontSize: 13, color: _C.black50),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 320,
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _kSkillSuggestions.length,
                itemBuilder: (_, i) {
                  final skill = _kSkillSuggestions[i];
                  final icon = _getSkillIcon(skill);
                  return _CategoryTile(
                    skill: skill,
                    icon: icon,
                    onTap: () {
                      Navigator.pop(context);
                      _openCategory(skill);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    final clientJobs = context.watch<JobProvider>().clientJobs;
    // DYNAMIC: always fetched from UserProvider — never hardcoded
    final firstName = user?.name.split(' ').first ?? 'there';

    // Categorize jobs
    final ongoingJobs = clientJobs.where((j) => 
      j.status == JobStatus.requested || j.status == JobStatus.confirmed).toList();
    final completedJobs = clientJobs.where((j) => 
      j.status == JobStatus.completed).toList();
    final upcomingJobs = ongoingJobs.where((j) =>
      j.scheduledDate.isAfter(DateTime.now())).toList()
      ..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));

    return Scaffold(
      backgroundColor: _C.white,
      appBar: _buildAppBar(user),
      body: RefreshIndicator(
        color: _C.maroon,
        displacement: 60,
        onRefresh: _loadData,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            // ── Greeting ──────────────────────────────────────────────
            SliverToBoxAdapter(child: _GreetingHeader(firstName: firstName)),

            // ── Smart Search Bar (skills appear ONLY here) ────────────
            SliverToBoxAdapter(child: _SmartSearchBar(onCategoryTap: _openCategory)),

            const SliverToBoxAdapter(child: SizedBox(height: 28)),

            // ── Quick Actions Grid ────────────────────────────────────
            const SliverToBoxAdapter(
              child: _SectionHeader(title: 'Quick Actions'),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverToBoxAdapter(
              child: _QuickActionsGrid(
                onBookService: () => _showCategorySelector(),
                onViewBookings: () => _showMyJobs(context, clientJobs),
                onSavedProfessionals: () {},
                onSupport: () {},
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 28)),

            // ── Divider ───────────────────────────────────────────────
            const SliverToBoxAdapter(child: _ThinDivider()),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // ── Ongoing Bookings ──────────────────────────────────────
            const SliverToBoxAdapter(
              child: _SectionHeader(title: 'Ongoing Bookings'),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverToBoxAdapter(
              child: ongoingJobs.isEmpty
                  ? const _EmptyHint(message: 'No ongoing bookings')
                  : _OngoingBookingsList(jobs: ongoingJobs),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 28)),

            // ── Divider ───────────────────────────────────────────────
            const SliverToBoxAdapter(child: _ThinDivider()),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // ── Upcoming Appointments ─────────────────────────────────
            const SliverToBoxAdapter(
              child: _SectionHeader(title: 'Upcoming Appointments'),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverToBoxAdapter(
              child: upcomingJobs.isEmpty
                  ? const _EmptyHint(message: 'No upcoming appointments')
                  : _UpcomingAppointmentsList(jobs: upcomingJobs),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 28)),

            // ── Divider ───────────────────────────────────────────────
            const SliverToBoxAdapter(child: _ThinDivider()),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // ── Recommended Professionals ─────────────────────────────
            const SliverToBoxAdapter(
              child: _SectionHeader(title: 'Recommended Professionals'),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverToBoxAdapter(
              child: _loadingTop
                  ? const _ShimmerRow()
                  : _topRated.isEmpty
                      ? const _EmptyHint(message: 'No professionals found yet')
                      : _RecommendedProfessionalsList(professionals: _topRated, onTap: _openProfile),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 28)),

            // ── Divider ───────────────────────────────────────────────
            const SliverToBoxAdapter(child: _ThinDivider()),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // ── Recent Activity ───────────────────────────────────────
            const SliverToBoxAdapter(
              child: _SectionHeader(title: 'Recent Activity'),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverToBoxAdapter(
              child: completedJobs.isEmpty
                  ? const _EmptyHint(message: 'No recent activity')
                  : _RecentActivityList(
                      jobs: completedJobs.take(5).toList(),
                      onReview: (job) => Navigator.of(context).pushNamed(
                        '/rate-provider',
                        arguments: {'jobId': job.id, 'providerId': job.providerId},
                      ),
                      onRebook: (job) => _openCategory(job.category),
                    ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  // ── AppBar ─────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(UserModel? user) {
    return AppBar(
      backgroundColor: _C.maroon,
      automaticallyImplyLeading: false,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      titleSpacing: 20,
      title: const Text(
        'Forge',
        style: TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 22,
          color: _C.white,
          letterSpacing: 0.8,
        ),
      ),
      actions: [
        // Notification icon with badge
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined, color: _C.white),
              tooltip: 'Notifications',
              onPressed: () => _showNotifications(context),
            ),
            if (_notifications.isNotEmpty)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    color: _C.yellow,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _notifications.length > 9 ? '9+' : '${_notifications.length}',
                    style: const TextStyle(
                      color: _C.black,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
        // Messages icon with unread badge
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.chat_bubble_outline_rounded, color: _C.white),
              tooltip: 'Messages',
              onPressed: () => Navigator.of(context).pushNamed('/chat-list'),
            ),
            if (context.watch<ChatProvider>().hasUnread)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    color: _C.green,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    context.watch<ChatProvider>().unreadCount > 9
                        ? '9+'
                        : '${context.watch<ChatProvider>().unreadCount}',
                    style: const TextStyle(
                      color: _C.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
        // Profile avatar
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => _showProfileMenu(),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: _C.white,
              backgroundImage: user?.photoUrl != null
                  ? NetworkImage(user!.photoUrl!)
                  : null,
              child: user?.photoUrl == null
                  ? Text(
                      user?.name.isNotEmpty == true 
                          ? user!.name[0].toUpperCase() 
                          : 'U',
                      style: const TextStyle(
                          color: _C.maroon,
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    )
                  : null,
            ),
          ),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: _C.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: _C.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Icon(Icons.notifications_rounded, color: _C.maroon, size: 24),
                  SizedBox(width: 12),
                  Text(
                    'Notifications',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _C.black,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (_notifications.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'No new notifications',
                  style: TextStyle(color: _C.black50, fontSize: 14),
                ),
              )
            else
              ...(_notifications.map((n) => ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _C.maroon.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.work_outline, color: _C.maroon, size: 20),
                ),
                title: Text(
                  n['title'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: _C.black,
                  ),
                ),
                subtitle: Text(
                  _formatTimeAgo(n['time'] as DateTime),
                  style: const TextStyle(fontSize: 12, color: _C.black50),
                ),
                trailing: const Icon(Icons.chevron_right, color: _C.black30),
                onTap: () {
                  Navigator.pop(context);
                  _openCategory(n['skill'] as String);
                },
              ))),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }

  void _showProfileMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _C.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: _C.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.swap_horiz_rounded, color: _C.maroon),
              title: const Text('Switch to Freelancer',
                  style: TextStyle(color: _C.black, fontWeight: FontWeight.w500)),
              onTap: () {
                Navigator.pop(context);
                _switchToFreelancer();
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: _C.maroon),
              title: const Text('Sign Out',
                  style: TextStyle(color: _C.black, fontWeight: FontWeight.w500)),
              onTap: () {
                Navigator.pop(context);
                _signOut();
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ── My Jobs sheet ──────────────────────────────────────────────────────────

  void _showMyJobs(BuildContext context, List jobs) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _C.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) {
        if (jobs.isEmpty) {
          return const SizedBox(
            height: 220,
            child: Center(
              child: Text('No bookings yet',
                  style: TextStyle(color: _C.black50, fontSize: 15)),
            ),
          );
        }
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          maxChildSize: 0.85,
          minChildSize: 0.3,
          expand: false,
          builder: (_, ctrl) => ListView.builder(
            controller: ctrl,
            padding: const EdgeInsets.only(top: 16, bottom: 24),
            itemCount: jobs.length + 1,
            itemBuilder: (context, i) {
              if (i == 0) {
                return const Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: Text(
                    'My Bookings',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _C.black),
                  ),
                );
              }
              final job = jobs[i - 1];
              return ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                title: Text(job.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, color: _C.black)),
                subtitle: Text('${job.category} • ${job.status}',
                    style: const TextStyle(color: _C.black50)),
                trailing: job.status == 'confirmed'
                    ? TextButton(
                        style: TextButton.styleFrom(
                            foregroundColor: _C.maroon),
                        onPressed: () {
                          context
                              .read<JobProvider>()
                              .updateJobStatus(job.id, JobStatus.completed);
                          Navigator.pop(context);
                          Navigator.of(context).pushNamed(
                            '/rate-provider',
                            arguments: {
                              'jobId': job.id,
                              'providerId': job.providerId,
                            },
                          );
                        },
                        child: const Text('Complete'),
                      )
                    : job.status == 'completed'
                        ? const Icon(Icons.check_circle_rounded,
                            color: _C.maroon)
                        : null,
              );
            },
          ),
        );
      },
    );
  }
}

// =============================================================================
// _ThinDivider
// =============================================================================

class _ThinDivider extends StatelessWidget {
  const _ThinDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 1,
      color: _C.border,
    );
  }
}

// =============================================================================
// _SectionHeader — bold BLACK title + animated expanding maroon underline
// =============================================================================

class _SectionHeader extends StatefulWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  State<_SectionHeader> createState() => _SectionHeaderState();
}

class _SectionHeaderState extends State<_SectionHeader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _underline;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600))
      ..forward();
    _underline = Tween<double>(begin: 0, end: 28).animate(
      CurvedAnimation(
          parent: _ctrl, curve: const Interval(0.3, 1.0, curve: Curves.easeOut)),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: _C.black,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 6),
          AnimatedBuilder(
            animation: _underline,
            builder: (_, _) => Container(
              width: _underline.value,
              height: 2,
              decoration: BoxDecoration(
                color: _C.maroon,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// _GreetingHeader — "Hi, {userName} 👋" with black text, maroon accent
// =============================================================================

class _GreetingHeader extends StatefulWidget {
  final String firstName;
  const _GreetingHeader({required this.firstName});

  @override
  State<_GreetingHeader> createState() => _GreetingHeaderState();
}

class _GreetingHeaderState extends State<_GreetingHeader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  late final Animation<double> _underline;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.35),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _underline = Tween<double>(begin: 0, end: 48).animate(
      CurvedAnimation(
          parent: _ctrl,
          curve: const Interval(0.4, 1.0, curve: Curves.easeOut)),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Container(
          width: double.infinity,
          color: _C.white,
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hi, ${widget.firstName} 👋',
                style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: _C.black,
                    height: 1.2),
              ),
              const SizedBox(height: 6),
              const Text(
                'Book trusted women professionals near you',
                style: TextStyle(
                    fontSize: 14,
                    color: _C.black50,
                    fontWeight: FontWeight.w400),
              ),
              const SizedBox(height: 12),
              AnimatedBuilder(
                animation: _underline,
                builder: (_, _) => Container(
                  width: _underline.value,
                  height: 2.5,
                  decoration: BoxDecoration(
                    color: _C.maroon,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Skill suggestions — ONLY shown in search bar when focused/typing
// Removed: Painter, Welder, Interior Site Supervisor, Flooring Installation Expert,
// Fire Safety Technician, Security Systems Installer, Modular Kitchen Installer
// =============================================================================

const List<String> _kSkillSuggestions = [
  'Car Mechanic',
  'Electrician',
  'Civil Engineer',
  'Plumber',
  'AC Technician',
  'Carpenter',
  'Gym Trainer',
  'Bike Repair Specialist',
  'Heavy Machinery Operator',
  'Construction Supervisor',
  'CCTV Installation Technician',
  'Network Technician',
  'Hardware Repair Specialist',
  'Auto Body Repair Expert',
  'Elevator Maintenance Technician',
  'Home Automation Technician',
  'Metal Fabrication Specialist',
];

// =============================================================================
// _SmartSearchBar — Skills ONLY appear here as suggestions on focus/type
// White bg, maroon border, rounded 30, black text, maroon search icon
// =============================================================================

class _SmartSearchBar extends StatefulWidget {
  final void Function(String) onCategoryTap;
  const _SmartSearchBar({required this.onCategoryTap});

  @override
  State<_SmartSearchBar> createState() => _SmartSearchBarState();
}

class _SmartSearchBarState extends State<_SmartSearchBar>
    with SingleTickerProviderStateMixin {
  final _ctrl = TextEditingController();
  final FocusNode _focus = FocusNode();
  bool _focused = false;
  bool _tapped = false;
  String? _selected;
  List<String> _suggestions = _kSkillSuggestions;

  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();

    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 250));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);

    _focus.addListener(() {
      if (!mounted) return;
      setState(() => _focused = _focus.hasFocus);
      if (_focus.hasFocus) {
        _fadeCtrl.forward();
      } else {
        _fadeCtrl.reverse();
      }
    });

    _ctrl.addListener(() {
      if (!mounted) return;
      final q = _ctrl.text.toLowerCase().trim();
      setState(() {
        _suggestions = q.isEmpty
            ? _kSkillSuggestions
            : _kSkillSuggestions
                .where((s) => s.toLowerCase().contains(q))
                .toList();
        if (_selected != null &&
            !_selected!.toLowerCase().contains(q)) {
          _selected = null;
        }
      });
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _onChipTap(String skill) {
    if (_selected == skill) {
      setState(() => _selected = null);
      _ctrl.clear();
      _focus.requestFocus();
    } else {
      setState(() => _selected = skill);
      _ctrl.text = skill;
      _ctrl.selection =
          TextSelection.fromPosition(TextPosition(offset: skill.length));
      _focus.unfocus();
      // Navigate to provider list for this category
      widget.onCategoryTap(skill);
    }
  }

  @override
  Widget build(BuildContext context) {
    final showPanel = _focused || _ctrl.text.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Text field ────────────────────────────────────────────────
        GestureDetector(
          onTapDown: (_) => setState(() => _tapped = true),
          onTapUp: (_) => setState(() => _tapped = false),
          onTapCancel: () => setState(() => _tapped = false),
          child: AnimatedScale(
            scale: _tapped ? 0.98 : 1.0,
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOut,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                boxShadow: _focused
                    ? [
                        BoxShadow(
                          color: _C.maroon.withValues(alpha: 0.15),
                          blurRadius: 12,
                          spreadRadius: 1,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: _C.black.withValues(alpha: 0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: TextField(
                controller: _ctrl,
                focusNode: _focus,
                style: const TextStyle(fontSize: 15, color: _C.black),
                decoration: InputDecoration(
                  hintText: 'Search for a professional…',
                  hintStyle: const TextStyle(color: _C.black30, fontSize: 14),
                  filled: true,
                  fillColor: _C.white,
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: _focused ? _C.maroon : _C.black50,
                    size: 22,
                  ),
                  suffixIcon: _ctrl.text.isNotEmpty
                      ? IconButton(
                          tooltip: 'Clear',
                          icon: const Icon(Icons.close_rounded,
                              color: _C.black50, size: 20),
                          onPressed: () {
                            _ctrl.clear();
                            setState(() => _selected = null);
                            _focus.requestFocus();
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: _C.maroon, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: _C.maroon, width: 1.5),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
              ),
            ),
          ),
        ),

        // ── Skill suggestion bubbles — fade-in, Wrap layout ───────────
        FadeTransition(
          opacity: _fadeAnim,
          child: AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            child: showPanel && _suggestions.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 10,
                      children: _suggestions.map((skill) {
                        final sel = _selected == skill;
                        return GestureDetector(
                          onTap: () => _onChipTap(skill),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOut,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 9),
                            decoration: BoxDecoration(
                              color: sel ? _C.maroon : _C.white,
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: _C.maroon,
                                width: sel ? 0 : 1.2,
                              ),
                              boxShadow: sel
                                  ? [
                                      BoxShadow(
                                        color: _C.maroon.withValues(alpha: 0.2),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      )
                                    ]
                                  : [],
                            ),
                            child: Text(
                              skill,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: sel
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: sel ? _C.white : _C.black,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Quick Actions Grid — 4 action buttons: Book, View Bookings, Saved, Support
// =============================================================================

class _QuickActionsGrid extends StatelessWidget {
  final VoidCallback onBookService;
  final VoidCallback onViewBookings;
  final VoidCallback onSavedProfessionals;
  final VoidCallback onSupport;
  
  const _QuickActionsGrid({
    required this.onBookService,
    required this.onViewBookings,
    required this.onSavedProfessionals,
    required this.onSupport,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(child: _QuickActionButton(
            icon: Icons.add_circle_outline_rounded,
            label: 'Book a Service',
            onTap: onBookService,
          )),
          const SizedBox(width: 12),
          Expanded(child: _QuickActionButton(
            icon: Icons.calendar_month_outlined,
            label: 'View Bookings',
            onTap: onViewBookings,
          )),
          const SizedBox(width: 12),
          Expanded(child: _QuickActionButton(
            icon: Icons.favorite_outline_rounded,
            label: 'Saved Pros',
            onTap: onSavedProfessionals,
          )),
          const SizedBox(width: 12),
          Expanded(child: _QuickActionButton(
            icon: Icons.headset_mic_outlined,
            label: 'Support',
            onTap: onSupport,
          )),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  State<_QuickActionButton> createState() => _QuickActionButtonState();
}

class _QuickActionButtonState extends State<_QuickActionButton> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) {
          setState(() => _pressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.95 : (_hovered ? 1.02 : 1.0),
          duration: const Duration(milliseconds: 200),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: _C.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _hovered ? _C.maroon : _C.border,
                width: _hovered ? 1.5 : 1,
              ),
              boxShadow: _hovered
                  ? [BoxShadow(
                      color: _C.maroon.withValues(alpha: 0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )]
                  : [],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(widget.icon, color: _C.maroon, size: 28),
                const SizedBox(height: 8),
                Text(
                  widget.label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _C.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Category Tile — for the category selector grid
// =============================================================================

class _CategoryTile extends StatefulWidget {
  final String skill;
  final IconData icon;
  final VoidCallback onTap;
  
  const _CategoryTile({
    required this.skill,
    required this.icon,
    required this.onTap,
  });

  @override
  State<_CategoryTile> createState() => _CategoryTileState();
}

class _CategoryTileState extends State<_CategoryTile> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) {
          setState(() => _pressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.identity()..scale(_pressed ? 0.95 : 1.0),
          transformAlignment: Alignment.center,
          decoration: BoxDecoration(
            color: _hovered ? _C.maroon.withValues(alpha: 0.05) : _C.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _hovered ? _C.maroon : _C.border,
              width: _hovered ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: _hovered 
                    ? _C.maroon.withValues(alpha: 0.1) 
                    : _C.black.withValues(alpha: 0.04),
                blurRadius: _hovered ? 10 : 6,
                offset: Offset(0, _hovered ? 4 : 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _hovered 
                      ? _C.maroon 
                      : _C.maroon.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(widget.icon, 
                  color: _hovered ? _C.white : _C.maroon, 
                  size: 22),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  widget.skill,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _hovered ? _C.maroon : _C.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Ongoing Bookings List — Card layout with status badges
// =============================================================================

class _OngoingBookingsList extends StatelessWidget {
  final List<JobModel> jobs;
  const _OngoingBookingsList({required this.jobs});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: jobs.length > 3 ? 3 : jobs.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (ctx, i) => _OngoingBookingCard(job: jobs[i]),
    );
  }
}

class _OngoingBookingCard extends StatefulWidget {
  final JobModel job;
  const _OngoingBookingCard({required this.job});

  @override
  State<_OngoingBookingCard> createState() => _OngoingBookingCardState();
}

class _OngoingBookingCardState extends State<_OngoingBookingCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('MMM d, yyyy • h:mm a').format(widget.job.scheduledDate);
    
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _C.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _hovered ? _C.maroon : _C.border,
            width: _hovered ? 1.5 : 1,
          ),
          boxShadow: _hovered
              ? [BoxShadow(
                  color: _C.maroon.withValues(alpha: 0.1),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                )]
              : [BoxShadow(
                  color: _C.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                )],
        ),
        child: Row(
          children: [
            // Calendar icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _C.maroon.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.work_outline_rounded, color: _C.maroon, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.job.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _C.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.job.category,
                    style: const TextStyle(
                      fontSize: 13,
                      color: _C.black50,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.schedule_rounded, 
                        size: 14, color: _C.black.withValues(alpha: 0.4)),
                      const SizedBox(width: 4),
                      Text(
                        dateStr,
                        style: TextStyle(
                          fontSize: 12,
                          color: _C.black.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _StatusBadge(status: widget.job.status),
                const SizedBox(height: 10),
                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () {
                    // Navigate to chat with provider
                    Navigator.of(context).pushNamed(
                      '/chat',
                      arguments: {'receiverId': widget.job.providerId},
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(color: _C.maroon),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.chat_bubble_outline_rounded, 
                          size: 14, color: _C.maroon),
                        SizedBox(width: 4),
                        Text('Message',
                          style: TextStyle(
                            fontSize: 12, 
                            fontWeight: FontWeight.w600,
                            color: _C.maroon,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    String displayText;
    
    switch (status.toLowerCase()) {
      case 'requested':
        bgColor = _C.yellow.withValues(alpha: 0.15);
        textColor = const Color(0xFFB8860B); // Dark golden
        displayText = 'PENDING';
        break;
      case 'confirmed':
        bgColor = _C.green.withValues(alpha: 0.15);
        textColor = _C.green;
        displayText = 'CONFIRMED';
        break;
      case 'completed':
        bgColor = _C.maroon.withValues(alpha: 0.1);
        textColor = _C.maroon;
        displayText = 'COMPLETED';
        break;
      default:
        bgColor = _C.black.withValues(alpha: 0.08);
        textColor = _C.black60;
        displayText = status.toUpperCase();
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: textColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// =============================================================================
// Upcoming Appointments List — Clean list with calendar icon
// =============================================================================

class _UpcomingAppointmentsList extends StatelessWidget {
  final List<JobModel> jobs;
  const _UpcomingAppointmentsList({required this.jobs});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: jobs.length > 4 ? 4 : jobs.length,
      separatorBuilder: (_, _) => const Divider(height: 1, color: _C.border),
      itemBuilder: (ctx, i) => _UpcomingAppointmentTile(job: jobs[i]),
    );
  }
}

class _UpcomingAppointmentTile extends StatelessWidget {
  final JobModel job;
  const _UpcomingAppointmentTile({required this.job});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('EEE, MMM d').format(job.scheduledDate);
    final timeStr = DateFormat('h:mm a').format(job.scheduledDate);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _C.maroon.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.calendar_today_rounded, color: _C.maroon, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  job.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _C.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  job.category,
                  style: const TextStyle(fontSize: 12, color: _C.black50),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                dateStr,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _C.black,
                ),
              ),
              Text(
                timeStr,
                style: const TextStyle(fontSize: 11, color: _C.black50),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Recommended Professionals — Horizontal scroll cards
// =============================================================================

class _RecommendedProfessionalsList extends StatelessWidget {
  final List<UserModel> professionals;
  final void Function(UserModel) onTap;
  const _RecommendedProfessionalsList({required this.professionals, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 210,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: professionals.length,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (_, i) => _RecommendedProfessionalCard(
          user: professionals[i],
          onTap: () => onTap(professionals[i]),
        ),
      ),
    );
  }
}

class _RecommendedProfessionalCard extends StatefulWidget {
  final UserModel user;
  final VoidCallback onTap;
  const _RecommendedProfessionalCard({required this.user, required this.onTap});

  @override
  State<_RecommendedProfessionalCard> createState() => _RecommendedProfessionalCardState();
}

class _RecommendedProfessionalCardState extends State<_RecommendedProfessionalCard> {
  bool _hovered = false;
  bool _btnPressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 155,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _C.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _hovered ? _C.maroon : _C.border,
              width: _hovered ? 1.5 : 1,
            ),
            boxShadow: _hovered
                ? [BoxShadow(
                    color: _C.maroon.withValues(alpha: 0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  )]
                : [BoxShadow(
                    color: _C.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Avatar with verified badge
              Stack(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: _C.maroon.withValues(alpha: 0.08),
                    backgroundImage: widget.user.photoUrl != null
                        ? NetworkImage(widget.user.photoUrl!)
                        : null,
                    child: widget.user.photoUrl == null
                        ? Text(
                            widget.user.name.isNotEmpty
                                ? widget.user.name[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                                color: _C.maroon,
                                fontSize: 24,
                                fontWeight: FontWeight.bold),
                          )
                        : null,
                  ),
                  // Green verified badge
                  if (widget.user.verified)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: _C.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: _C.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 12,
                          color: _C.white,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Name (bold black)
              Text(
                widget.user.name.split(' ').first,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _C.black),
              ),
              
              // Skill
              if (widget.user.skills.isNotEmpty)
                Text(
                  widget.user.skills.first,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: _C.black50),
                ),
              
              // Rating (YELLOW star)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.star_rounded, size: 16, color: _C.yellow),
                  const SizedBox(width: 3),
                  Text(
                    widget.user.rating.toStringAsFixed(1),
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _C.black),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '(${widget.user.totalRatings})',
                    style: TextStyle(
                        fontSize: 11,
                        color: _C.black.withValues(alpha: 0.4)),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              
              // Book Now button
              GestureDetector(
                onTapDown: (_) => setState(() => _btnPressed = true),
                onTapUp: (_) {
                  setState(() => _btnPressed = false);
                  widget.onTap();
                },
                onTapCancel: () => setState(() => _btnPressed = false),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  width: double.infinity,
                  height: 34,
                  decoration: BoxDecoration(
                    color: _btnPressed ? _C.maroonDark : _C.maroon,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: _btnPressed
                        ? []
                        : [BoxShadow(
                            color: _C.maroon.withValues(alpha: 0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )],
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Book Now',
                    style: TextStyle(
                        color: _C.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Recent Activity List — Completed services with review/rebook actions
// =============================================================================

class _RecentActivityList extends StatelessWidget {
  final List<JobModel> jobs;
  final void Function(JobModel) onReview;
  final void Function(JobModel) onRebook;
  const _RecentActivityList({
    required this.jobs,
    required this.onReview,
    required this.onRebook,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: jobs.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (ctx, i) => _RecentActivityCard(
        job: jobs[i],
        onReview: () => onReview(jobs[i]),
        onRebook: () => onRebook(jobs[i]),
      ),
    );
  }
}

class _RecentActivityCard extends StatefulWidget {
  final JobModel job;
  final VoidCallback onReview;
  final VoidCallback onRebook;
  const _RecentActivityCard({
    required this.job,
    required this.onReview,
    required this.onRebook,
  });

  @override
  State<_RecentActivityCard> createState() => _RecentActivityCardState();
}

class _RecentActivityCardState extends State<_RecentActivityCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('MMM d, yyyy').format(widget.job.scheduledDate);
    
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        scale: _hovered ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _C.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _hovered ? _C.maroon : _C.border),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _C.maroon.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.check_circle_outline_rounded, color: _C.maroon, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.job.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _C.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$dateStr • Completed',
                      style: const TextStyle(fontSize: 12, color: _C.black50),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: widget.onReview,
                    style: TextButton.styleFrom(
                      foregroundColor: _C.maroon,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    ),
                    child: const Text('Review',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                  OutlinedButton(
                    onPressed: widget.onRebook,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _C.maroon,
                      side: const BorderSide(color: _C.maroon),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Rebook',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Shimmer loading row
// =============================================================================

class _ShimmerRow extends StatefulWidget {
  const _ShimmerRow();

  @override
  State<_ShimmerRow> createState() => _ShimmerRowState();
}

class _ShimmerRowState extends State<_ShimmerRow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat();
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: 4,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (_, _) => AnimatedBuilder(
          animation: _anim,
          builder: (_, _) {
            return Container(
              width: 155,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Color.lerp(
                  const Color(0xFFF0F0F0),
                  const Color(0xFFE0E0E0),
                  _anim.value,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// =============================================================================
// Empty hint
// =============================================================================

class _EmptyHint extends StatelessWidget {
  final String message;
  const _EmptyHint({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Center(
        child: Text(
          message,
          style: const TextStyle(color: _C.black50, fontSize: 14),
        ),
      ),
    );
  }
}
