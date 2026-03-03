import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:forge/providers/auth_provider.dart';
import 'package:forge/providers/user_provider.dart';
import 'package:forge/providers/job_provider.dart';
import 'package:forge/providers/chat_provider.dart';
import 'package:forge/models/job_model.dart';
import 'package:forge/models/user_model.dart';
import 'package:forge/core/constants/app_constants.dart';
import 'package:intl/intl.dart';

// =============================================================================
// Design tokens — MAROON #A82323 + BLACK + WHITE  (matches client_home)
// =============================================================================
class _C {
  static const Color maroon      = Color(0xFFA82323);
  static const Color maroonDark  = Color(0xFF7A1818);
  static const Color maroonLight = Color(0xFFFDF2F2);
  static const Color white       = Color(0xFFFFFFFF);
  static const Color black       = Color(0xFF000000);
  static const Color black80     = Color(0xCC000000);
  static const Color black60     = Color(0x99000000);
  static const Color black50     = Color(0x80000000);
  static const Color black30     = Color(0x4D000000);
  static const Color black10     = Color(0x1A000000);
  static const Color border      = Color(0xFFE8E8E8);
  static const Color green       = Color(0xFF2E7D32);
  static const Color yellow      = Color(0xFFFFC107);
}

class ProviderHomeScreen extends StatefulWidget {
  const ProviderHomeScreen({super.key});

  @override
  State<ProviderHomeScreen> createState() => _ProviderHomeScreenState();
}

class _ProviderHomeScreenState extends State<ProviderHomeScreen> {
  int selectedTab = 0;

  // ── Local sample jobs (used when Firestore is empty) ────────────────────
  late List<JobModel> _sampleJobs;

  @override
  void initState() {
    super.initState();
    _sampleJobs = _buildSampleJobs();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  static List<JobModel> _buildSampleJobs() {
    final now = DateTime.now();
    return [
      // ── Incoming (requested) ──
      JobModel(
        id: 'sample-1',
        clientId: 'c1',
        clientName: 'Ananya Sharma',
        providerId: 'me',
        category: 'Electrician',
        title: 'Ceiling Fan Installation',
        description: 'Install 3 ceiling fans in living room & bedrooms',
        status: JobStatus.requested,
        scheduledDate: now.add(const Duration(days: 2)),
        createdAt: now.subtract(const Duration(hours: 3)),
      ),
      JobModel(
        id: 'sample-2',
        clientId: 'c2',
        clientName: 'Priya Patel',
        providerId: 'me',
        category: 'Electrician',
        title: 'Wiring Repair',
        description: 'Short circuit issue in kitchen area',
        status: JobStatus.requested,
        scheduledDate: now.add(const Duration(days: 3)),
        createdAt: now.subtract(const Duration(hours: 1)),
      ),
      JobModel(
        id: 'sample-3',
        clientId: 'c3',
        clientName: 'Meera Reddy',
        providerId: 'me',
        category: 'Electrician',
        title: 'Smart Switch Setup',
        description: 'Install smart switches in 2 rooms',
        status: JobStatus.requested,
        scheduledDate: now.add(const Duration(days: 5)),
        createdAt: now.subtract(const Duration(minutes: 30)),
      ),
      // ── Upcoming (confirmed / active) ──
      JobModel(
        id: 'sample-4',
        clientId: 'c4',
        clientName: 'Kavitha Iyer',
        providerId: 'me',
        category: 'Electrician',
        title: 'Full House Wiring',
        description: 'Complete rewiring for 2BHK apartment',
        status: JobStatus.confirmed,
        scheduledDate: now.add(const Duration(days: 1)),
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      JobModel(
        id: 'sample-5',
        clientId: 'c5',
        clientName: 'Deepa Nair',
        providerId: 'me',
        category: 'Electrician',
        title: 'Generator Maintenance',
        description: 'Annual generator service check',
        status: JobStatus.confirmed,
        scheduledDate: now.add(const Duration(days: 4)),
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      // ── Completed ──
      JobModel(
        id: 'sample-6',
        clientId: 'c6',
        clientName: 'Lakshmi Rao',
        providerId: 'me',
        category: 'Electrician',
        title: 'LED Panel Installation',
        description: 'Install LED panels in office cabin',
        status: JobStatus.completed,
        scheduledDate: now.subtract(const Duration(days: 3)),
        createdAt: now.subtract(const Duration(days: 7)),
      ),
      JobModel(
        id: 'sample-7',
        clientId: 'c7',
        clientName: 'Sunita Verma',
        providerId: 'me',
        category: 'Electrician',
        title: 'Inverter Setup',
        description: 'Set up 1.5 KVA inverter with battery',
        status: JobStatus.completed,
        scheduledDate: now.subtract(const Duration(days: 5)),
        createdAt: now.subtract(const Duration(days: 10)),
      ),
      JobModel(
        id: 'sample-8',
        clientId: 'c8',
        clientName: 'Ritu Gupta',
        providerId: 'me',
        category: 'Electrician',
        title: 'MCB Panel Replacement',
        description: 'Replace old MCB panel with new modular panel',
        status: JobStatus.completed,
        scheduledDate: now.subtract(const Duration(days: 8)),
        createdAt: now.subtract(const Duration(days: 12)),
      ),
    ];
  }

  /// Accept a sample job locally — move from requested → confirmed.
  void _acceptSampleJob(String id) {
    setState(() {
      _sampleJobs = _sampleJobs.map((j) {
        if (j.id == id && j.status == JobStatus.requested) {
          return JobModel(
            id: j.id,
            clientId: j.clientId,
            clientName: j.clientName,
            providerId: j.providerId,
            category: j.category,
            title: j.title,
            description: j.description,
            status: JobStatus.confirmed,
            scheduledDate: j.scheduledDate,
            createdAt: j.createdAt,
          );
        }
        return j;
      }).toList();
    });
  }

  /// Reject a sample job locally.
  void _rejectSampleJob(String id) {
    setState(() {
      _sampleJobs = _sampleJobs.where((j) => j.id != id).toList();
    });
  }

  /// Complete a sample job locally.
  void _completeSampleJob(String id) {
    setState(() {
      _sampleJobs = _sampleJobs.map((j) {
        if (j.id == id && j.status == JobStatus.confirmed) {
          return JobModel(
            id: j.id,
            clientId: j.clientId,
            clientName: j.clientName,
            providerId: j.providerId,
            category: j.category,
            title: j.title,
            description: j.description,
            status: JobStatus.completed,
            scheduledDate: j.scheduledDate,
            createdAt: j.createdAt,
          );
        }
        return j;
      }).toList();
    });
  }

  Future<void> _loadData() async {
    final uid = context.read<AuthProvider>().uid;
    if (uid != null) {
      context.read<JobProvider>().listenToProviderJobs(uid);
      context.read<UserProvider>().loadUser(uid);
      context.read<ChatProvider>().startListening(uid);
    }
  }

  Future<void> _switchToClient() async {
    final uid = context.read<AuthProvider>().uid;
    if (uid == null) return;

    final userProvider = context.read<UserProvider>();
    context.read<JobProvider>().cancelSubscriptions();
    await userProvider.switchRole(uid);

    if (!mounted) return;

    if (userProvider.user?.name.isEmpty ?? true) {
      Navigator.of(context).pushReplacementNamed('/client-setup');
    } else {
      Navigator.of(context).pushReplacementNamed('/client-home');
    }
  }

  Future<void> _signOut() async {
    context.read<JobProvider>().cancelSubscriptions();
    context.read<ChatProvider>().stopListening();
    await context.read<AuthProvider>().signOut();
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/login');
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
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: _C.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.swap_horiz_rounded, color: _C.maroon),
              title: const Text('Switch to Client',
                  style: TextStyle(color: _C.black, fontWeight: FontWeight.w500)),
              onTap: () { Navigator.pop(context); _switchToClient(); },
            ),
            ListTile(
              leading: const Icon(Icons.edit_rounded, color: _C.maroon),
              title: const Text('Edit Profile',
                  style: TextStyle(color: _C.black, fontWeight: FontWeight.w500)),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushNamed('/provider-setup');
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: _C.maroon),
              title: const Text('Sign Out',
                  style: TextStyle(color: _C.black, fontWeight: FontWeight.w500)),
              onTap: () { Navigator.pop(context); _signOut(); },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final jobProvider = context.watch<JobProvider>();
    final chatProvider = context.watch<ChatProvider>();
    final user = userProvider.user;

    // Detect new user: no ratings, no completed jobs
    final isNewUser = user != null &&
        user.totalRatings == 0 &&
        user.completedJobs == 0 &&
        user.rating == 0.0;

    // Use Firestore jobs when available; show samples only for demo users
    final hasRealJobs = jobProvider.providerJobs.isNotEmpty;
    final showSamples = !hasRealJobs && !isNewUser;

    final incoming = hasRealJobs
        ? jobProvider.incomingJobs
        : showSamples
            ? _sampleJobs.where((j) => j.status == JobStatus.requested).toList()
            : <JobModel>[];
    final active = hasRealJobs
        ? jobProvider.activeJobs
        : showSamples
            ? _sampleJobs.where((j) => j.status == JobStatus.confirmed).toList()
            : <JobModel>[];
    final completed = hasRealJobs
        ? jobProvider.completedJobs
        : showSamples
            ? _sampleJobs.where((j) => j.status == JobStatus.completed).toList()
            : <JobModel>[];

    final tabs = [incoming, active, completed];

    final firstName = user?.name.split(' ').first ?? 'there';

    return Scaffold(
      backgroundColor: _C.white,
      appBar: _buildAppBar(user, chatProvider),
      body: RefreshIndicator(
        color: _C.maroon,
        displacement: 60,
        onRefresh: _loadData,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            // ── Greeting ──────────────────────────────────────
            SliverToBoxAdapter(child: _GreetingHeader(firstName: firstName)),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // ── Profile Summary Card ──────────────────────────
            if (user != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _ProfileCard(user: user, userProvider: userProvider),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // ── Stats Row ─────────────────────────────────────
            if (user != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _StatsRow(user: user),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 28)),

            // ── Divider ───────────────────────────────────────
            const SliverToBoxAdapter(child: _ThinDivider()),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Reviews & Ratings section removed

            // ── Section Title ─────────────────────────────────
            const SliverToBoxAdapter(
              child: _SectionHeader(title: 'My Jobs'),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // ── Segmented Tab Buttons ─────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      _TabButton(
                        title: 'Incoming',
                        count: incoming.length,
                        isSelected: selectedTab == 0,
                        onTap: () => setState(() => selectedTab = 0),
                      ),
                      _TabButton(
                        title: 'Active',
                        count: active.length,
                        isSelected: selectedTab == 1,
                        onTap: () => setState(() => selectedTab = 1),
                      ),
                      _TabButton(
                        title: 'Completed',
                        count: completed.length,
                        isSelected: selectedTab == 2,
                        onTap: () => setState(() => selectedTab = 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // ── Job List ──────────────────────────────────────
            if (tabs[selectedTab].isEmpty)
              const SliverToBoxAdapter(
                child: _EmptyHint(message: 'No jobs in this category'),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    child: _JobCard(
                      job: tabs[selectedTab][i],
                      provider: jobProvider,
                      isSample: showSamples,
                      onAcceptSample: _acceptSampleJob,
                      onRejectSample: _rejectSampleJob,
                      onCompleteSample: _completeSampleJob,
                    ),
                  ),
                  childCount: tabs[selectedTab].length,
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  // ── AppBar — matches client_home_screen pattern ───────────────────────────

  PreferredSizeWidget _buildAppBar(UserModel? user, ChatProvider chatProvider) {
    return AppBar(
      backgroundColor: _C.maroon,
      automaticallyImplyLeading: false,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      toolbarHeight: 64,
      titleSpacing: 24,
      title: const Text(
        'Forge',
        style: TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 28,
          color: _C.white,
          letterSpacing: 1.0,
        ),
      ),
      actions: [
        // Chat icon with unread badge
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.chat_bubble_outline_rounded, color: _C.white),
              tooltip: 'Messages',
              onPressed: () => Navigator.of(context).pushNamed('/chat-list'),
            ),
            if (chatProvider.hasUnread)
              Positioned(
                right: 8, top: 8,
                child: Container(
                  width: 16, height: 16,
                  decoration: const BoxDecoration(
                    color: _C.yellow, shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    chatProvider.unreadCount > 9 ? '9+' : '${chatProvider.unreadCount}',
                    style: const TextStyle(
                      color: _C.black, fontSize: 9, fontWeight: FontWeight.bold,
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
            onTap: _showProfileMenu,
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
// _SectionHeader — animated maroon underline (matches client)
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
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.3, 1.0, curve: Curves.easeOut)),
    );
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

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
              fontSize: 20, fontWeight: FontWeight.w800, color: _C.black,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 6),
          AnimatedBuilder(
            animation: _underline,
            builder: (_, __) => Container(
              width: _underline.value, height: 2,
              decoration: BoxDecoration(
                color: _C.maroon, borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// _GreetingHeader — "Hi, {name} 👋" with animated underline (matches client)
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
      vsync: this, duration: const Duration(milliseconds: 800),
    )..forward();

    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.35), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _underline = Tween<double>(begin: 0, end: 48).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.4, 1.0, curve: Curves.easeOut)),
    );
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

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
                    fontSize: 28, fontWeight: FontWeight.w800, color: _C.black, height: 1.2),
              ),
              const SizedBox(height: 6),
              const Text(
                'Manage your jobs and grow your business',
                style: TextStyle(fontSize: 14, color: _C.black50, fontWeight: FontWeight.w400),
              ),
              const SizedBox(height: 12),
              AnimatedBuilder(
                animation: _underline,
                builder: (_, __) => Container(
                  width: _underline.value, height: 2.5,
                  decoration: BoxDecoration(
                    color: _C.maroon, borderRadius: BorderRadius.circular(2),
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
// _ProfileCard — avatar, name, skills, availability toggle
// =============================================================================

class _ProfileCard extends StatefulWidget {
  final UserModel user;
  final UserProvider userProvider;
  const _ProfileCard({required this.user, required this.userProvider});

  @override
  State<_ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<_ProfileCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _C.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _hovered ? _C.maroon : _C.border,
            width: _hovered ? 1.5 : 1,
          ),
          boxShadow: _hovered
              ? [BoxShadow(color: _C.maroon.withValues(alpha: 0.1), blurRadius: 14, offset: const Offset(0, 4))]
              : [BoxShadow(color: _C.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: _C.maroon.withValues(alpha: 0.08),
                  backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
                  child: user.photoUrl == null
                      ? Text(
                          user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                          style: const TextStyle(color: _C.maroon, fontSize: 22, fontWeight: FontWeight.bold),
                        )
                      : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(user.name,
                                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: _C.black)),
                          ),
                          if (user.verified) ...[
                            const SizedBox(width: 6),
                            Container(
                              width: 20, height: 20,
                              decoration: BoxDecoration(
                                color: _C.green, shape: BoxShape.circle,
                                border: Border.all(color: _C.white, width: 2),
                              ),
                              child: const Icon(Icons.check, size: 12, color: _C.white),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(user.skills.join(', '),
                          style: const TextStyle(fontSize: 13, color: _C.black50),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text('${user.experience} yrs • ${user.location}',
                          style: TextStyle(fontSize: 12, color: _C.black.withValues(alpha: 0.4))),
                    ],
                  ),
                ),
              ],
            ),
            if (user.bio.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(user.bio,
                  style: const TextStyle(fontSize: 13, color: _C.black60, height: 1.4),
                  maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
            const SizedBox(height: 14),
            Row(
              children: [
                Row(
                  children: [
                    const Icon(Icons.star_rounded, size: 18, color: _C.yellow),
                    const SizedBox(width: 4),
                    Text(user.rating.toStringAsFixed(1),
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _C.black)),
                    const SizedBox(width: 4),
                    Text('(${user.totalRatings})',
                        style: TextStyle(fontSize: 12, color: _C.black.withValues(alpha: 0.4))),
                  ],
                ),
                const Spacer(),
                Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 8, height: 8,
                      decoration: BoxDecoration(
                        color: user.available ? _C.green : _C.black30,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(user.available ? 'Available' : 'Offline',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                            color: user.available ? _C.green : _C.black50)),
                    const SizedBox(width: 4),
                    SizedBox(
                      height: 28,
                      child: Switch(
                        value: user.available,
                        activeColor: _C.maroon,
                        onChanged: (val) {
                          widget.userProvider.updateUser(user.uid, {'available': val});
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// _StatsRow — Rating, Completed, Reviews
// =============================================================================

class _StatsRow extends StatelessWidget {
  final UserModel user;
  const _StatsRow({required this.user});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatCard(label: 'Rating', value: user.rating.toStringAsFixed(1), icon: Icons.star_rounded),
        const SizedBox(width: 10),
        _StatCard(label: 'Completed', value: user.completedJobs.toString(), icon: Icons.check_circle_outline),
        const SizedBox(width: 10),
        _StatCard(label: 'Reviews', value: user.totalRatings.toString(), icon: Icons.rate_review_outlined),
      ],
    );
  }
}

class _StatCard extends StatefulWidget {
  final String label;
  final String value;
  final IconData icon;
  const _StatCard({required this.label, required this.value, required this.icon});

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: _C.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _hovered ? _C.maroon : _C.border,
              width: _hovered ? 1.5 : 1,
            ),
            boxShadow: _hovered
                ? [BoxShadow(color: _C.maroon.withValues(alpha: 0.08), blurRadius: 10, offset: const Offset(0, 3))]
                : [BoxShadow(color: _C.black.withValues(alpha: 0.03), blurRadius: 4, offset: const Offset(0, 2))],
          ),
          child: Column(
            children: [
              Icon(widget.icon, color: _C.maroon, size: 20),
              const SizedBox(height: 6),
              Text(widget.value,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _C.black)),
              const SizedBox(height: 2),
              Text(widget.label,
                  style: const TextStyle(fontSize: 11, color: _C.black50)),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// _TabButton — segmented tab with hover + press effect
// =============================================================================

class _TabButton extends StatefulWidget {
  final String title;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;
  const _TabButton({
    required this.title,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_TabButton> createState() => _TabButtonState();
}

class _TabButtonState extends State<_TabButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: widget.isSelected
                  ? _C.maroon
                  : _hovered
                      ? _C.maroon.withValues(alpha: 0.06)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                Text(
                  widget.title,
                  style: TextStyle(
                    color: widget.isSelected ? _C.white : (_hovered ? _C.maroon : _C.black60),
                    fontWeight: widget.isSelected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
                if (widget.count > 0) ...[
                  const SizedBox(height: 2),
                  Text(
                    '${widget.count}',
                    style: TextStyle(
                      color: widget.isSelected ? _C.white.withValues(alpha: 0.8) : _C.black30,
                      fontSize: 11, fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// _JobCard — individual job with hover effects and action buttons
// =============================================================================

class _JobCard extends StatefulWidget {
  final JobModel job;
  final JobProvider provider;
  final bool isSample;
  final void Function(String id)? onAcceptSample;
  final void Function(String id)? onRejectSample;
  final void Function(String id)? onCompleteSample;
  const _JobCard({
    required this.job,
    required this.provider,
    this.isSample = false,
    this.onAcceptSample,
    this.onRejectSample,
    this.onCompleteSample,
  });

  @override
  State<_JobCard> createState() => _JobCardState();
}

class _JobCardState extends State<_JobCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final job = widget.job;
    final dateStr = DateFormat('EEE, d MMM yyyy').format(job.scheduledDate);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _C.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _hovered ? _C.maroon : _C.border,
            width: _hovered ? 1.5 : 1,
          ),
          boxShadow: _hovered
              ? [BoxShadow(color: _C.maroon.withValues(alpha: 0.1), blurRadius: 14, offset: const Offset(0, 4))]
              : [BoxShadow(color: _C.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            // Job icon
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: _hovered ? _C.maroon : _C.maroon.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.work_outline_rounded,
                  color: _hovered ? _C.white : _C.maroon, size: 22),
            ),
            const SizedBox(width: 14),
            // Job info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(job.title,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _C.black)),
                  const SizedBox(height: 4),
                  Text(job.clientName,
                      style: const TextStyle(fontSize: 13, color: _C.black50)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_rounded, size: 13, color: _C.black.withValues(alpha: 0.4)),
                      const SizedBox(width: 4),
                      Text(dateStr,
                          style: TextStyle(fontSize: 12, color: _C.black.withValues(alpha: 0.5))),
                    ],
                  ),
                ],
              ),
            ),
            // Status + actions
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _StatusBadge(status: job.status),
                const SizedBox(height: 10),
                _buildActions(job),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActions(JobModel job) {
    switch (job.status) {
      case JobStatus.requested:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ActionChip(
              label: 'Accept',
              filled: true,
              onTap: () {
                if (widget.isSample) {
                  widget.onAcceptSample?.call(job.id);
                } else {
                  widget.provider.updateJobStatus(job.id, JobStatus.confirmed);
                  Navigator.of(context).pushNamed('/chat', arguments: {
                    'jobId': job.id,
                    'otherUid': job.clientId,
                    'otherName': job.clientName,
                  });
                }
              },
            ),
            const SizedBox(width: 6),
            _ActionChip(
              label: 'Reject',
              filled: false,
              onTap: () {
                if (widget.isSample) {
                  widget.onRejectSample?.call(job.id);
                } else {
                  widget.provider.updateJobStatus(job.id, JobStatus.rejected);
                }
              },
            ),
          ],
        );
      case JobStatus.confirmed:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ActionChip(
              label: 'Message',
              filled: false,
              icon: Icons.chat_bubble_outline_rounded,
              onTap: () => Navigator.of(context).pushNamed('/chat', arguments: {
                'jobId': job.id,
                'otherUid': job.clientId,
                'otherName': job.clientName,
              }),
            ),
            const SizedBox(width: 6),
            _ActionChip(
              label: 'Complete',
              filled: true,
              onTap: () {
                if (widget.isSample) {
                  widget.onCompleteSample?.call(job.id);
                } else {
                  widget.provider.updateJobStatus(job.id, JobStatus.completed);
                }
              },
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

// =============================================================================
// _ActionChip — small button with hover for job actions
// =============================================================================

class _ActionChip extends StatefulWidget {
  final String label;
  final bool filled;
  final IconData? icon;
  final VoidCallback onTap;
  const _ActionChip({required this.label, required this.filled, this.icon, required this.onTap});

  @override
  State<_ActionChip> createState() => _ActionChipState();
}

class _ActionChipState extends State<_ActionChip> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) { setState(() => _pressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: widget.filled
              ? (_pressed ? _C.maroonDark : _C.maroon)
              : _C.white,
          border: widget.filled ? null : Border.all(color: _C.maroon),
          borderRadius: BorderRadius.circular(8),
          boxShadow: _pressed
              ? []
              : widget.filled
                  ? [BoxShadow(color: _C.maroon.withValues(alpha: 0.2), blurRadius: 6, offset: const Offset(0, 2))]
                  : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.icon != null) ...[
              Icon(widget.icon, size: 14,
                  color: widget.filled ? _C.white : _C.maroon),
              const SizedBox(width: 4),
            ],
            Text(widget.label,
                style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600,
                  color: widget.filled ? _C.white : _C.maroon,
                )),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// _StatusBadge — matches client_home_screen
// =============================================================================

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
        textColor = const Color(0xFFB8860B);
        displayText = 'PENDING';
        break;
      case 'confirmed':
        bgColor = _C.green.withValues(alpha: 0.15);
        textColor = _C.green;
        displayText = 'ACTIVE';
        break;
      case 'completed':
        bgColor = _C.maroon.withValues(alpha: 0.1);
        textColor = _C.maroon;
        displayText = 'DONE';
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
      child: Text(displayText,
          style: TextStyle(
            fontSize: 10, fontWeight: FontWeight.w700,
            color: textColor, letterSpacing: 0.5,
          )),
    );
  }
}

// =============================================================================
// _SampleReviewsList — sample client reviews for the freelancer dashboard
// =============================================================================
// _EmptyHint
// =============================================================================

class _EmptyHint extends StatelessWidget {
  final String message;
  const _EmptyHint({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.inbox_outlined, size: 48, color: _C.black.withValues(alpha: 0.15)),
            const SizedBox(height: 12),
            Text(message,
                style: const TextStyle(color: _C.black50, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
