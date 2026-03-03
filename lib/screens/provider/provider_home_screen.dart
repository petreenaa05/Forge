
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:forge/providers/auth_provider.dart';
import 'package:forge/providers/user_provider.dart';
import 'package:forge/providers/job_provider.dart';
import 'package:forge/models/job_model.dart';
import 'package:forge/models/user_model.dart';
import 'package:forge/core/constants/app_constants.dart';
import 'package:intl/intl.dart';

class ProviderHomeScreen extends StatefulWidget {
  const ProviderHomeScreen({super.key});

  @override
  State<ProviderHomeScreen> createState() => _ProviderHomeScreenState();
}

class _ProviderHomeScreenState extends State<ProviderHomeScreen> {
  int selectedTab = 0;
  // color constants for brand system
  static const Color primaryColor = Color(0xFFA82323);
  static const Color secondaryBg = Color.fromARGB(255, 227, 227, 223);

  @override
  void initState() {
    super.initState();
    final uid = context.read<AuthProvider>().uid;
    if (uid != null) {
      context.read<JobProvider>().listenToProviderJobs(uid);
      context.read<UserProvider>().loadUser(uid);
    }
  }

  Future<void> _switchToClient() async {
    final uid = context.read<AuthProvider>().uid;
    if (uid == null) return;

    final userProvider = context.read<UserProvider>();
    context.read<JobProvider>().cancelSubscriptions();
    await userProvider.switchRole(uid);

    if (!mounted) return;

    // If name is empty, go to setup
    if (userProvider.user?.name.isEmpty ?? true) {
      Navigator.of(context).pushReplacementNamed('/client-setup');
    } else {
      Navigator.of(context).pushReplacementNamed('/client-home');
    }
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

    final tabs = [
      jobProvider.incomingJobs,
      jobProvider.activeJobs,
      jobProvider.completedJobs
    ];

    return Scaffold(
      backgroundColor: secondaryBg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

            /// ================= HEADER =================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              decoration: const BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(32),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // top row with title, chat icon & menu
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Freelancer",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chat_outlined, color: Colors.white),
                            onPressed: () =>
                                Navigator.of(context).pushNamed('/chat-list'),
                          ),
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert, color: Colors.white),
                            onSelected: (v) {
                              if (v == 'switch') _switchToClient();
                              if (v == 'logout') _signOut();
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(
                                value: 'switch',
                                child: Text('\uD83D\uDD04 Switch to Client Mode'),
                              ),
                              PopupMenuItem(
                                value: 'logout',
                                child: Text('\uD83D\uDEAA Sign Out'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // profile summary card
                  if (user != null) _profileCard(user, userProvider),

                  const SizedBox(height: 16),

                  // reputation dashboard
                  if (user != null) _statsRow(user),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // availability toggle moved into profile card; remove separate section

            const SizedBox(height: 24),

            /// ================= SEGMENTED JOB TABS =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    _tabButton("Incoming Requests", 0),
                    _tabButton("Active Jobs", 1),
                    _tabButton("Completed", 2),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            /// ================= JOB LIST =================
            if (tabs[selectedTab].isEmpty)
              Center(
                child: Text(
                  "No jobs available",
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 15),
                ),
              )
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount;

                  if (constraints.maxWidth > 1200) {
                    crossAxisCount = 3; // Desktop
                  } else if (constraints.maxWidth > 800) {
                    crossAxisCount = 2; // Tablet
                  } else {
                    crossAxisCount = 1; // Mobile
                  }

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.15,
                    ),
                    itemCount: tabs[selectedTab].length,
                    itemBuilder: (_, i) {
                      final job = tabs[selectedTab][i];
                      return _enhancedJobTile(job, jobProvider);
                    },
                  );
                },
              ),
          ],
        ),
      ),
      ), // close SafeArea
      // end of SafeArea and Column
      floatingActionButton: FloatingActionButton.extended(
        // use light background with white text for contrast
        backgroundColor: const Color.fromARGB(255, 137, 36, 14),
        onPressed: () =>
            Navigator.of(context).pushNamed('/provider-setup'),
        label: const Text("Edit Profile", style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.edit, color: Colors.white),
      ),
    );
  }


  /// SEGMENTED TAB BUTTON
  Widget _tabButton(String title, int index) {
    final selected = selectedTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => selectedTab = index);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: selected ? Colors.white : Colors.black54,
                fontWeight:
                    selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- helper widgets ----------------

  Widget _profileCard(UserModel user, UserProvider userProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundImage: user.photoUrl != null
                    ? NetworkImage(user.photoUrl!)
                    : null,
                // avoid deprecated withOpacity
                backgroundColor: primaryColor.withValues(alpha: 0.1),
                child: user.photoUrl == null
                    ? Text(user.name.isNotEmpty ? user.name[0] : '?')
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.skills.join(', '),
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${user.experience} yrs • ${user.location}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              if (user.verified)
                const Icon(Icons.verified, color: Color.fromARGB(255, 42, 169, 27)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            user.bio,
            style: const TextStyle(fontSize: 14),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.star, size: 16, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(user.rating.toStringAsFixed(1)),
                ],
              ),
              Row(
                children: [
                  const Text('Available'),
                  Switch(
                    value: user.available,
                    activeThumbColor: primaryColor,
                    onChanged: (val) {
                      userProvider.updateUser(user.uid, {'available': val});
                    },
                  )
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _statsRow(UserModel user) {
    Widget statCard(String label, String value) {
      return Expanded(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
            ],
          ),
          child: Column(
            children: [
              Text(value,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        statCard('Rating', user.rating.toStringAsFixed(1)),
        statCard('Completed', user.completedJobs.toString()),
        statCard('Reviews', user.totalRatings.toString()),
        statCard('Status', user.available ? 'Online' : 'Offline'),
      ],
    );
  }

  Widget? _jobActions(JobModel job, JobProvider provider) {
    switch (job.status) {
      case JobStatus.requested:
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(
              width: 120,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  provider.updateJobStatus(job.id, JobStatus.confirmed);
                  Navigator.of(context).pushNamed('/chat', arguments: job);
                },
                child: const Text('Accept'),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 120,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryColor,
                  side: const BorderSide(color: primaryColor),
                  backgroundColor: Colors.white,
                ),
                onPressed: () {
                  provider.updateJobStatus(job.id, JobStatus.rejected);
                },
                child: const Text('Reject'),
              ),
            ),
          ],
        );
      case JobStatus.confirmed:
        return ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
          onPressed: () {
            provider.updateJobStatus(job.id, JobStatus.completed);
          },
          child: const Text('Mark as Completed'),
        );
      default:
        return null;
    }
  }

  // enhanced job tile with additional details
  Widget _enhancedJobTile(JobModel job, JobProvider provider) {
    String dateStr = DateFormat('EEE, d MMM yyyy').format(job.scheduledDate);

    return Align(
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Container(
          padding: const EdgeInsets.all(20),
          // removed vertical margin to tighten spacing
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // top icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.work, color: Colors.white, size: 24),
              ),
              const SizedBox(height: 12),
              // title & client
              Text(job.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87)),
              const SizedBox(height: 4),
              Text(job.clientName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: Colors.black54)),
              const SizedBox(height: 8),
              // location
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_on, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  const Text('Adyar, Chennai',
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 4),
              // date
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(dateStr, style: const TextStyle(fontSize: 12)),
                ],
              ),
              const SizedBox(height: 12),
              // payment and status
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('₹1500',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: primaryColor)),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(12)),
                    child: const Text('Pending',
                        style: TextStyle(fontSize: 10, color: Colors.orange)),
                  )
                ],
              ),
              const SizedBox(height: 12),
              // action buttons
              if (_jobActions(job, provider) != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [Expanded(child: _jobActions(job, provider)!)],
                )
            ],
          ),
        ),
      ),
    );
  }
}
