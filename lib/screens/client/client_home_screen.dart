import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:forge/models/user_model.dart';
import 'package:forge/providers/auth_provider.dart';
import 'package:forge/providers/user_provider.dart';
import 'package:forge/providers/job_provider.dart';
import 'package:forge/services/firestore_service.dart';
import 'package:forge/core/theme/app_theme.dart';
import 'package:forge/core/constants/app_constants.dart';
import 'package:forge/widgets/provider_card.dart';

/// Client home screen — Urban Company-inspired layout with:
///   - Greeting header
///   - Search bar
///   - Category grid
///   - Top Rated Professionals
///   - Available Now section
class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  final FirestoreService _db = FirestoreService();
  final TextEditingController _searchCtrl = TextEditingController();

  List<UserModel> _topRated = [];
  List<UserModel> _availableNow = [];
  bool _loadingTop = true;
  bool _loadingAvailable = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final uid = context.read<AuthProvider>().uid;
    if (uid != null) {
      context.read<UserProvider>().loadUser(uid);
      context.read<JobProvider>().listenToClientJobs(uid);
    }

    try {
      final top = await _db.getTopRatedFreelancers();
      if (mounted) setState(() { _topRated = top; _loadingTop = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingTop = false);
    }

    try {
      final avail = await _db.getAvailableFreelancers();
      if (mounted) setState(() { _availableNow = avail; _loadingAvailable = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingAvailable = false);
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    final clientJobs = context.watch<JobProvider>().clientJobs;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            const Text('⚒️ ', style: TextStyle(fontSize: 22)),
            const Text('Forge'),
          ],
        ),
        actions: [
          // My Jobs badge
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.work_outline),
                tooltip: 'My Jobs',
                onPressed: () => _showMyJobs(context, clientJobs),
              ),
              if (clientJobs.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppTheme.accent,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${clientJobs.length}',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.chat_outlined),
            tooltip: 'Chats',
            onPressed: () => Navigator.of(context).pushNamed('/chat-list'),
          ),
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'switch') _switchToFreelancer();
              if (v == 'logout') _signOut();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'switch', child: Text('🔄 Switch to Freelancer Mode')),
              PopupMenuItem(value: 'logout', child: Text('🚪 Sign Out')),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Greeting ─────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Text(
                  'Hello, ${user?.name.split(' ').first ?? 'there'} 👋',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'What service do you need today?',
                  style: TextStyle(color: AppTheme.textMedium, fontSize: 14),
                ),
              ),
              const SizedBox(height: 20),

              // ── Search bar ───────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    hintText: 'Search services…',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: const Icon(Icons.tune, size: 20),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Categories grid ──────────────────────────
              _sectionHeader('Service Categories'),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.95,
                ),
                itemCount: kCategories.length,
                itemBuilder: (_, i) {
                  final cat = kCategories[i];
                  return _CategoryTile(
                    category: cat,
                    onTap: () => _openCategory(cat.name),
                  );
                },
              ),
              const SizedBox(height: 28),

              // ── Top Rated ────────────────────────────────
              _sectionHeader('Top Rated Professionals'),
              const SizedBox(height: 8),
              if (_loadingTop)
                const Center(child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ))
              else if (_topRated.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: Text('No professionals found yet',
                        style: TextStyle(color: AppTheme.textMedium)),
                  ),
                )
              else
                ...(_topRated.map((f) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: ProviderCard(user: f, onTap: () => _openProfile(f)),
                    ))),
              const SizedBox(height: 28),

              // ── Available Now ────────────────────────────
              _sectionHeader('Available Now'),
              const SizedBox(height: 8),
              if (_loadingAvailable)
                const Center(child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ))
              else if (_availableNow.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: Text('No one available right now',
                        style: TextStyle(color: AppTheme.textMedium)),
                  ),
                )
              else
                SizedBox(
                  height: 160,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _availableNow.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (_, i) {
                      final f = _availableNow[i];
                      return _AvailableChip(user: f, onTap: () => _openProfile(f));
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppTheme.textDark,
        ),
      ),
    );
  }

  // -- My Jobs bottom sheet --
  void _showMyJobs(BuildContext context, List jobs) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        if (jobs.isEmpty) {
          return const SizedBox(
            height: 200,
            child: Center(child: Text('No bookings yet')),
          );
        }

        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          maxChildSize: 0.85,
          minChildSize: 0.3,
          expand: false,
          builder: (_, ctrl) {
            return ListView.builder(
              controller: ctrl,
              padding: const EdgeInsets.only(top: 16, bottom: 16),
              itemCount: jobs.length + 1,
              itemBuilder: (context, i) {
                if (i == 0) {
                  return const Padding(
                    padding: EdgeInsets.only(left: 20, bottom: 12),
                    child: Text('My Bookings',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark)),
                  );
                }
                final job = jobs[i - 1];
                return ListTile(
                  title: Text(job.title,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text('${job.category} • ${job.status}'),
                  trailing: job.status == 'confirmed'
                      ? TextButton(
                          onPressed: () {
                            context
                                .read<JobProvider>()
                                .updateJobStatus(job.id, JobStatus.completed);
                            Navigator.pop(context);
                            // Navigate to rating
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
                          ? const Icon(Icons.check_circle,
                              color: AppTheme.verified)
                          : null,
                );
              },
            );
          },
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Category tile widget
// ---------------------------------------------------------------------------
class _CategoryTile extends StatelessWidget {
  final AppCategory category;
  final VoidCallback onTap;

  const _CategoryTile({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: category.color,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(category.emoji, style: const TextStyle(fontSize: 32)),
              const SizedBox(height: 8),
              Text(
                category.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Horizontal available-now chips
// ---------------------------------------------------------------------------
class _AvailableChip extends StatelessWidget {
  final UserModel user;
  final VoidCallback onTap;

  const _AvailableChip({required this.user, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 8),
            Text(
              user.name.split(' ').first,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star_rounded, size: 14, color: Color(0xFFFBBF24)),
                const SizedBox(width: 2),
                Text(
                  user.rating.toStringAsFixed(1),
                  style: const TextStyle(fontSize: 12, color: AppTheme.textMedium),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFD1FAE5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Available',
                style: TextStyle(fontSize: 10, color: Color(0xFF059669)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
