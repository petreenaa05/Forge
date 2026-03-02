import 'package:flutter/material.dart';
import 'package:forge/models/user_model.dart';
import 'package:forge/core/theme/app_theme.dart';
import 'package:forge/widgets/rating_widget.dart';

class ProviderCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback onTap;

  const ProviderCard({
    super.key,
    required this.user,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.black12,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Avatar with optional verified badge
              Stack(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppTheme.primary,
                    backgroundImage: user.photoUrl != null
                        ? NetworkImage(user.photoUrl!)
                        : null,
                    child: user.photoUrl == null
                        ? Text(
                            user.name.isNotEmpty
                                ? user.name[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  if (user.verified)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_circle,
                          color: AppTheme.verified,
                          size: 16,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              // Info section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppTheme.textDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    // Rating stars
                    RatingWidget(
                      rating: user.rating,
                      size: 14,
                      showNumber: true,
                    ),
                    const SizedBox(height: 5),
                    // Skills chips (first 2)
                    if (user.skills.isNotEmpty)
                      Wrap(
                        spacing: 4,
                        children: user.skills.take(2).map((skill) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3E8FF),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              skill,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppTheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    const SizedBox(height: 4),
                    // Experience + availability
                    Row(
                      children: [
                        Text(
                          '${user.experience} yrs exp',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textMedium,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: user.available
                                ? const Color(0xFF10B981)
                                : const Color(0xFF9CA3AF),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          user.available ? 'Available' : 'Unavailable',
                          style: TextStyle(
                            fontSize: 12,
                            color: user.available
                                ? const Color(0xFF10B981)
                                : const Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Trailing chevron
              const Icon(
                Icons.chevron_right,
                color: AppTheme.textMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
