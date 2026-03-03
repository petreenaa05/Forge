import 'package:flutter/material.dart';

/// Professional chat header with user info and job reference
class ChatHeader extends StatelessWidget {
  final String userName;
  final String? userImage;
  final bool isVerified;
  final bool isOnline;
  final String? lastSeen;
  final String jobReference;
  final VoidCallback onBackPressed;

  const ChatHeader({
    super.key,
    required this.userName,
    this.userImage,
    this.isVerified = false,
    this.isOnline = false,
    this.lastSeen,
    required this.jobReference,
    required this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: const Color(0xFFE5E7EB), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Back button
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
                onPressed: onBackPressed,
                color: const Color(0xFF2D2D2D),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 12),

              // Profile image
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isOnline
                        ? const Color(0xFF6D9E51)
                        : const Color(0xFFE5E7EB),
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  backgroundColor: const Color(0xFFF3F4F6),
                  backgroundImage: userImage != null
                      ? NetworkImage(userImage!)
                      : null,
                  child: userImage == null
                      ? const Icon(Icons.person, color: Color(0xFF9CA3AF))
                      : null,
                ),
              ),
              const SizedBox(width: 12),

              // User info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(
                          userName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2D2D2D),
                          ),
                        ),
                        if (isVerified) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.verified,
                            size: 16,
                            color: Color(0xFF6D9E51),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isOnline
                          ? 'Online'
                          : lastSeen != null
                          ? 'Last seen $lastSeen'
                          : 'Offline',
                      style: TextStyle(
                        fontSize: 12,
                        color: isOnline
                            ? const Color(0xFF6D9E51)
                            : const Color(0xFF9CA3AF),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      jobReference,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF6B7280),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // More options
              IconButton(
                icon: const Icon(Icons.more_vert, size: 22),
                onPressed: () {},
                color: const Color(0xFF6B7280),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
