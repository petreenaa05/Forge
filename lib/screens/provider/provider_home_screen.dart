import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:forge/providers/auth_provider.dart';
import 'package:forge/providers/user_provider.dart';
import 'package:forge/providers/job_provider.dart';
import 'package:forge/core/theme/app_theme.dart';
import 'package:forge/core/constants/app_constants.dart';
import 'package:forge/widgets/job_card.dart';
import 'package:forge/widgets/rating_widget.dart';

/// Freelancer home screen.
/// Shows incoming requests, active jobs, completed jobs and a profile/rating
/// dashboard.  Contains the "Switch to Client Mode" button.
class ProviderHomeScreen extends StatefulWidget {
  const ProviderHomeScreen({super.key});

  @override
  State<ProviderHomeScreen> createState() => _ProviderHomeScreenState();
}

class _ProviderHomeScreenState extends State<ProviderHomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);

    // Start listening to provider's jobs
    final uid = context.read<AuthProvider>().uid;
    if (uid != null) {
      context.read<JobProvider>().listenToProviderJobs(uid);
      // Refresh user data
      context.read<UserProvider>().loadUser(uid);
    }
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _switchToClient() async {
    final uid = context.read<AuthProvider>().uid;
    if (uid == null) return;

    final userProvider = context.read<UserProvider>();
    context.read<JobProvider>().cancelSubscriptions();
    await userProvider.switchRole(uid);

    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/client-home');
  }

  Future<void> _signOut() async {
    context.read<JobProvider>().cancelSubscriptions();
    await context.read<AuthProvider>().signOut();
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final jobProvider = context.watch<JobProvider>();
    final user = userProvider.user;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            const Text('⚒️ ', style: TextStyle(fontSize: 22)),
            const Text('Forge'),
            if (user?.verified == true) ...[
              const SizedBox(width: 6),
              const Icon(Icons.check_circle, color: AppTheme.verified, size: 18),
            ],
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_outlined),
            tooltip: 'Chats',
            onPressed: () => Navigator.of(context).pushNamed('/chat-list'),
          ),
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'switch') _switchToClient();
              if (v == 'edit') Navigator.of(context).pushNamed('/provider-setup');
              if (v == 'logout') _signOut();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'switch', child: Text('🔄 Switch to Client Mode')),
              PopupMenuItem(value: 'edit', child: Text('✏️ Edit Profile')),
              PopupMenuItem(value: 'logout', child: Text('🚪 Sign Out')),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textMedium,
          indicatorColor: AppTheme.primary,
          tabs: [
            Tab(text: 'Incoming (${jobProvider.incomingJobs.length})'),
            Tab(text: 'Active (${jobProvider.activeJobs.length})'),
            Tab(text: 'Done (${jobProvider.completedJobs.length})'),
          ],
        ),
      ),
      body: Column(
        children: [
          // ── Profile dashboard card ──────────────────────
          if (user != null)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
                ],
              ),
              child: Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppTheme.primary,
                    backgroundImage:
                        user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
                    child: user.photoUrl == null
                        ? Text(
                            user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name.isNotEmpty ? user.name : 'Freelancer',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        RatingWidget(rating: user.rating, size: 14, showNumber: true),
                      ],
                    ),
                  ),
                  // Stats
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${user.completedJobs}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                        ),
                      ),
                      const Text(
                        'Jobs Done',
                        style: TextStyle(fontSize: 11, color: AppTheme.textMedium),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // ── Tab views ────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                // Incoming
                _JobList(
                  jobs: jobProvider.incomingJobs,
                  emptyIcon: Icons.inbox_outlined,
                  emptyText: 'No incoming requests',
                  buildActions: (job) => Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => jobProvider.updateJobStatus(
                              job.id, JobStatus.rejected),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                          ),
                          child: const Text('Reject'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => jobProvider.updateJobStatus(
                              job.id, JobStatus.confirmed),
                          child: const Text('Accept'),
                        ),
                      ),
                    ],
                  ),
                ),

                // Active
                _JobList(
                  jobs: jobProvider.activeJobs,
                  emptyIcon: Icons.play_circle_outline,
                  emptyText: 'No active jobs',
                  buildActions: (job) => ElevatedButton.icon(
                    onPressed: () =>
                        Navigator.of(context).pushNamed('/chat', arguments: {
                      'jobId': job.id,
                      'otherUid': job.clientId,
                      'otherName': job.clientName,
                    }),
                    icon: const Icon(Icons.chat_bubble_outline, size: 18),
                    label: const Text('Chat with Client'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 42),
                    ),
                  ),
                ),

                // Completed
                _JobList(
                  jobs: jobProvider.completedJobs,
                  emptyIcon: Icons.check_circle_outline,
                  emptyText: 'No completed jobs yet',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Reusable job list with empty state
// ---------------------------------------------------------------------------
typedef _ActionBuilder = Widget Function(dynamic job);

class _JobList extends StatelessWidget {
  final List jobs;
  final IconData emptyIcon;
  final String emptyText;
  final _ActionBuilder? buildActions;

  const _JobList({
    required this.jobs,
    required this.emptyIcon,
    required this.emptyText,
    this.buildActions,
  });

  @override
  Widget build(BuildContext context) {
    if (jobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(emptyIcon, size: 56, color: AppTheme.textMedium.withOpacity(0.4)),
            const SizedBox(height: 12),
            Text(
              emptyText,
              style: const TextStyle(color: AppTheme.textMedium, fontSize: 15),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 80),
      itemCount: jobs.length,
      itemBuilder: (_, i) {
        final job = jobs[i];
        return JobCard(
          job: job,
          actions: buildActions?.call(job),
        );
      },
    );
  }
}
