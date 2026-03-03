import 'package:flutter/material.dart';

class _C {
  static const Color primary = Color(0xFFA82323);
  static const Color secondary = Color(0xFFFEFFD3);
  static const Color tertiary = Color(0xFF6D9E51);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF1A1A1A);
  static const Color textSubtle = Color(0xFF6A6A6A);
  static const Color border = Color(0xFFECECEC);
}

class CommunityPost {
  final String id;
  final String authorName;
  final String role;
  final bool isVerified;
  final String contributionScore;
  final DateTime timestamp;
  final String title;
  final String description;
  final String category;
  final bool isUrgent;
  final List<String> tags;
  final int supportCount;
  final int commentCount;
  final bool offeredHelp;

  const CommunityPost({
    required this.id,
    required this.authorName,
    required this.role,
    required this.isVerified,
    required this.contributionScore,
    required this.timestamp,
    required this.title,
    required this.description,
    required this.category,
    required this.isUrgent,
    required this.tags,
    required this.supportCount,
    required this.commentCount,
    this.offeredHelp = false,
  });

  CommunityPost copyWith({
    int? supportCount,
    int? commentCount,
    bool? offeredHelp,
  }) {
    return CommunityPost(
      id: id,
      authorName: authorName,
      role: role,
      isVerified: isVerified,
      contributionScore: contributionScore,
      timestamp: timestamp,
      title: title,
      description: description,
      category: category,
      isUrgent: isUrgent,
      tags: tags,
      supportCount: supportCount ?? this.supportCount,
      commentCount: commentCount ?? this.commentCount,
      offeredHelp: offeredHelp ?? this.offeredHelp,
    );
  }
}

class CommunityController extends ChangeNotifier {
  static const List<String> categories = [
    'All',
    'Technical Help',
    'Career Advice',
    'Urgent Support',
    'Collaboration',
    'Learning',
  ];

  String selectedCategory = 'All';

  final List<CommunityPost> _posts = [
    CommunityPost(
      id: 'p1',
      authorName: 'Ananya Mehta',
      role: 'Freelancer',
      isVerified: true,
      contributionScore: 'Contribution Score: 148',
      timestamp: DateTime.now().subtract(const Duration(minutes: 18)),
      title: 'Need guidance on estimating electrical rewiring effort',
      description:
          'I am preparing a quote for a 2-floor residential rewiring assignment. I need a structured checklist to estimate labor hours, material overhead, and risk factors so I can present a fair and professional cost breakup.',
      category: 'Technical Help',
      isUrgent: false,
      tags: const ['#Electrician', '#ProjectEstimation'],
      supportCount: 23,
      commentCount: 9,
    ),
    CommunityPost(
      id: 'p2',
      authorName: 'Farah Khan',
      role: 'Client',
      isVerified: false,
      contributionScore: 'Contribution Score: 62',
      timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 8)),
      title: 'Urgent: Need advice for safe temporary plumbing fix',
      description:
          'A pipe joint started leaking and the site visit is scheduled tomorrow morning. Please suggest safe temporary measures to reduce damage tonight and what information I should prepare for the professional visit.',
      category: 'Urgent Support',
      isUrgent: true,
      tags: const ['#Plumbing', '#HomeSafety'],
      supportCount: 31,
      commentCount: 15,
    ),
    CommunityPost(
      id: 'p3',
      authorName: 'Suhani Iyer',
      role: 'Freelancer',
      isVerified: true,
      contributionScore: 'Contribution Score: 201',
      timestamp: DateTime.now().subtract(const Duration(hours: 3, minutes: 24)),
      title: 'Looking to collaborate on interior + civil package proposals',
      description:
          'I frequently get requests requiring both interior and civil scope. I would like to collaborate with verified civil engineers to submit stronger bundled proposals with clear task ownership and timelines.',
      category: 'Collaboration',
      isUrgent: false,
      tags: const ['#CivilEngineering', '#InteriorDesign'],
      supportCount: 17,
      commentCount: 6,
    ),
  ];

  List<CommunityPost> get filteredPosts {
    if (selectedCategory == 'All') return _posts;
    return _posts.where((post) => post.category == selectedCategory).toList();
  }

  List<String> get topContributors => const [
    'Suhani Iyer',
    'Ananya Mehta',
    'Kavya Nair',
  ];

  void selectCategory(String value) {
    selectedCategory = value;
    notifyListeners();
  }

  void supportPost(String id) {
    final index = _posts.indexWhere((post) => post.id == id);
    if (index == -1) return;
    _posts[index] = _posts[index].copyWith(
      supportCount: _posts[index].supportCount + 1,
    );
    notifyListeners();
  }

  void offerHelp(String id) {
    final index = _posts.indexWhere((post) => post.id == id);
    if (index == -1) return;
    _posts[index] = _posts[index].copyWith(offeredHelp: true);
    notifyListeners();
  }

  void addPost({
    required String title,
    required String description,
    required String category,
    required bool isUrgent,
    required List<String> tags,
  }) {
    _posts.insert(
      0,
      CommunityPost(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        authorName: 'You',
        role: 'Freelancer',
        isVerified: true,
        contributionScore: 'Contribution Score: 104',
        timestamp: DateTime.now(),
        title: title,
        description: description,
        category: category,
        isUrgent: isUrgent,
        tags: tags,
        supportCount: 0,
        commentCount: 0,
      ),
    );
    notifyListeners();
  }
}

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  late final CommunityController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CommunityController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openCreatePostModal() async {
    final result = await showModalBottomSheet<_CreatePostData>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CreatePostModal(),
    );

    if (result == null) return;

    _controller.addPost(
      title: result.title,
      description: result.description,
      category: result.category,
      isUrgent: result.isUrgent,
      tags: result.tags,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFFCEB), _C.secondary],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (_, __) {
              return Column(
                children: [
                  _NetworkHeader(
                    onBack: () => Navigator.of(context).maybePop(),
                    onCreatePost: _openCreatePostModal,
                  ),
                  CategoryFilterBar(
                    categories: CommunityController.categories,
                    selectedCategory: _controller.selectedCategory,
                    onSelect: _controller.selectCategory,
                  ),
                  const SizedBox(height: 8),
                  const _CommunityGuidelinesBanner(),
                  const SizedBox(height: 8),
                  _TopContributorsCard(names: _controller.topContributors),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
                      itemCount: _controller.filteredPosts.length,
                      itemBuilder: (_, index) {
                        final post = _controller.filteredPosts[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: CommunityPostCard(
                            post: post,
                            onSupport: () {
                              _controller.supportPost(post.id);
                            },
                            onComment: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Comments panel coming next.'),
                                ),
                              );
                            },
                            onOfferHelp: () {
                              _controller.offerHelp(post.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Support offered! Opening chat with the member...',
                                  ),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                              Navigator.of(context).pushNamed('/support-chat');
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _NetworkHeader extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onCreatePost;
  const _NetworkHeader({required this.onBack, required this.onCreatePost});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded, color: _C.black),
          ),
          const SizedBox(width: 4),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Forge Network',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: _C.black,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Connect. Support. Grow Together.',
                  style: TextStyle(
                    fontSize: 14,
                    color: _C.textSubtle,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          FilledButton.icon(
            onPressed: onCreatePost,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Create Post'),
            style: FilledButton.styleFrom(
              backgroundColor: _C.primary,
              foregroundColor: _C.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryFilterBar extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onSelect;

  const CategoryFilterBar({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, index) {
          final category = categories[index];
          final isActive = category == selectedCategory;
          return FilterChip(
            label: Text(category),
            selected: isActive,
            onSelected: (_) => onSelect(category),
            showCheckmark: false,
            labelStyle: TextStyle(
              color: isActive ? _C.white : _C.black,
              fontWeight: FontWeight.w600,
            ),
            backgroundColor: _C.white,
            selectedColor: _C.primary,
            side: BorderSide(color: isActive ? _C.primary : _C.border),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: categories.length,
      ),
    );
  }
}

class CommunityPostCard extends StatefulWidget {
  final CommunityPost post;
  final VoidCallback onSupport;
  final VoidCallback onComment;
  final VoidCallback onOfferHelp;

  const CommunityPostCard({
    super.key,
    required this.post,
    required this.onSupport,
    required this.onComment,
    required this.onOfferHelp,
  });

  @override
  State<CommunityPostCard> createState() => _CommunityPostCardState();
}

class _CommunityPostCardState extends State<CommunityPostCard> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final post = widget.post;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      decoration: BoxDecoration(
        color: _C.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: post.isUrgent ? _C.primary.withValues(alpha: 0.35) : _C.border,
          width: post.isUrgent ? 1.4 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _C.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
          if (post.isUrgent)
            BoxShadow(
              color: _C.primary.withValues(alpha: 0.12),
              blurRadius: 14,
              spreadRadius: 1,
            ),
        ],
      ),
      child: Column(
        children: [
          if (post.isVerified)
            Container(
              height: 4,
              decoration: const BoxDecoration(
                color: _C.tertiary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: _C.primary.withValues(alpha: 0.12),
                      child: Text(
                        post.authorName[0],
                        style: const TextStyle(
                          color: _C.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  post.authorName,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: _C.black,
                                  ),
                                ),
                              ),
                              if (post.isVerified) ...[
                                const SizedBox(width: 6),
                                const Icon(
                                  Icons.verified_rounded,
                                  size: 16,
                                  color: _C.tertiary,
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${post.role} • ${_timeAgo(post.timestamp)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: _C.textSubtle,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            post.contributionScore,
                            style: TextStyle(
                              fontSize: 12,
                              color: _C.primary.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (post.isUrgent)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _C.primary.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Urgent',
                          style: TextStyle(
                            color: _C.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  post.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _C.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  post.description,
                  maxLines: expanded ? null : 3,
                  overflow: expanded ? null : TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _C.textSubtle,
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () => setState(() => expanded = !expanded),
                  child: Text(
                    expanded ? 'Read Less' : 'Read More',
                    style: const TextStyle(
                      color: _C.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: post.tags
                      .map(
                        (tag) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _C.secondary,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: _C.border),
                          ),
                          child: Text(
                            tag,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _C.black,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 12),
                const Divider(color: _C.border, height: 1),
                const SizedBox(height: 10),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final compact = constraints.maxWidth < 420;
                    return compact
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: 10,
                                runSpacing: 8,
                                children: [
                                  _ActionItem(
                                    icon: Icons.volunteer_activism_outlined,
                                    label: 'Support ${post.supportCount}',
                                    onTap: widget.onSupport,
                                  ),
                                  _ActionItem(
                                    icon: Icons.mode_comment_outlined,
                                    label: 'Comment ${post.commentCount}',
                                    onTap: widget.onComment,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              FilledButton.icon(
                                onPressed: widget.onOfferHelp,
                                style: FilledButton.styleFrom(
                                  backgroundColor: _C.tertiary,
                                  foregroundColor: _C.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.handshake_outlined,
                                  size: 18,
                                ),
                                label: Text(
                                  post.offeredHelp
                                      ? 'Help Offered'
                                      : 'Offer Help',
                                ),
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              _ActionItem(
                                icon: Icons.volunteer_activism_outlined,
                                label: 'Support ${post.supportCount}',
                                onTap: widget.onSupport,
                              ),
                              const SizedBox(width: 12),
                              _ActionItem(
                                icon: Icons.mode_comment_outlined,
                                label: 'Comment ${post.commentCount}',
                                onTap: widget.onComment,
                              ),
                              const Spacer(),
                              FilledButton.icon(
                                onPressed: widget.onOfferHelp,
                                style: FilledButton.styleFrom(
                                  backgroundColor: _C.tertiary,
                                  foregroundColor: _C.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.handshake_outlined,
                                  size: 18,
                                ),
                                label: Text(
                                  post.offeredHelp
                                      ? 'Help Offered'
                                      : 'Offer Help',
                                ),
                              ),
                            ],
                          );
                  },
                ),
                if (post.offeredHelp) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _C.tertiary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Helper badge added to your comment profile for this thread.',
                      style: TextStyle(
                        fontSize: 12,
                        color: _C.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class _ActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 18, color: _C.textSubtle),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                color: _C.textSubtle,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CreatePostModal extends StatefulWidget {
  const CreatePostModal({super.key});

  @override
  State<CreatePostModal> createState() => _CreatePostModalState();
}

class _CreatePostModalState extends State<CreatePostModal> {
  final titleCtrl = TextEditingController();
  final descriptionCtrl = TextEditingController();
  final tagsCtrl = TextEditingController();

  String category = CommunityController.categories[1];
  bool urgent = false;

  @override
  void dispose() {
    titleCtrl.dispose();
    descriptionCtrl.dispose();
    tagsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: const BoxDecoration(
          color: _C.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  height: 4,
                  width: 46,
                  decoration: BoxDecoration(
                    color: _C.border,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Create Post',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: _C.black,
                ),
              ),
              const SizedBox(height: 14),
              _InputField(label: 'Title', controller: titleCtrl),
              const SizedBox(height: 12),
              _InputField(
                label: 'Description',
                controller: descriptionCtrl,
                maxLines: 5,
              ),
              const SizedBox(height: 12),
              const Text(
                'Select Category',
                style: TextStyle(fontWeight: FontWeight.w600, color: _C.black),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: category,
                items: CommunityController.categories
                    .where((value) => value != 'All')
                    .map(
                      (value) =>
                          DropdownMenuItem(value: value, child: Text(value)),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => category = value);
                  }
                },
                decoration: _inputDecoration(),
              ),
              const SizedBox(height: 12),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: urgent,
                activeColor: _C.primary,
                title: const Text(
                  'Mark as Urgent',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                onChanged: (value) => setState(() => urgent = value),
              ),
              const SizedBox(height: 8),
              _InputField(
                label: 'Add Skill Tags (comma separated)',
                controller: tagsCtrl,
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    final title = titleCtrl.text.trim();
                    final desc = descriptionCtrl.text.trim();
                    if (title.isEmpty || desc.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Title and Description are required.'),
                        ),
                      );
                      return;
                    }

                    final tags = tagsCtrl.text
                        .split(',')
                        .map((t) => t.trim())
                        .where((t) => t.isNotEmpty)
                        .map((t) => t.startsWith('#') ? t : '#$t')
                        .toList();

                    Navigator.of(context).pop(
                      _CreatePostData(
                        title: title,
                        description: desc,
                        category: category,
                        isUrgent: urgent,
                        tags: tags,
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: _C.primary,
                    foregroundColor: _C.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Post'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFFFAFAFA),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _C.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _C.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _C.primary),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final int maxLines;

  const _InputField({
    required this.label,
    required this.controller,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, color: _C.black),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFFAFAFA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _C.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _C.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _C.primary),
            ),
          ),
        ),
      ],
    );
  }
}

class _CreatePostData {
  final String title;
  final String description;
  final String category;
  final bool isUrgent;
  final List<String> tags;

  const _CreatePostData({
    required this.title,
    required this.description,
    required this.category,
    required this.isUrgent,
    required this.tags,
  });
}

class _TopContributorsCard extends StatelessWidget {
  final List<String> names;
  const _TopContributorsCard({required this.names});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _C.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _C.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.workspace_premium_outlined, color: _C.tertiary),
          const SizedBox(width: 8),
          const Text(
            'Top Contributors:',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              names.join(' • '),
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: _C.textSubtle),
            ),
          ),
        ],
      ),
    );
  }
}

class _CommunityGuidelinesBanner extends StatelessWidget {
  const _CommunityGuidelinesBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _C.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _C.primary.withValues(alpha: 0.18)),
      ),
      child: const Row(
        children: [
          Icon(Icons.rule_folder_outlined, color: _C.primary),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Community Guidelines: Keep discussions professional, skill-focused, and respectful.',
              style: TextStyle(fontWeight: FontWeight.w600, color: _C.black),
            ),
          ),
        ],
      ),
    );
  }
}
