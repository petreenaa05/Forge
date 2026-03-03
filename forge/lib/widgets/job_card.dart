import 'package:flutter/material.dart';
import 'package:forge/models/job_model.dart';
import 'package:forge/core/constants/app_constants.dart';
import 'package:forge/core/theme/app_theme.dart';
import 'package:intl/intl.dart';

class JobCard extends StatelessWidget {
  final JobModel job;
  final Widget? actions;

  const JobCard({
    super.key,
    required this.job,
    this.actions,
  });

  Color _statusColor(String status) {
    switch (status) {
      case JobStatus.requested:
        return const Color(0xFFF97316);
      case JobStatus.confirmed:
        return const Color(0xFF3B82F6);
      case JobStatus.completed:
        return const Color(0xFF10B981);
      case JobStatus.rejected:
        return const Color(0xFFEF4444);
      default:
        return AppTheme.textMedium;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case JobStatus.requested:
        return 'Requested';
      case JobStatus.confirmed:
        return 'Confirmed';
      case JobStatus.completed:
        return 'Completed';
      case JobStatus.rejected:
        return 'Rejected';
      default:
        return status;
    }
  }

  String _categoryEmoji(String category) {
    switch (category) {
      case 'Gym Trainer':
        return '🏋️';
      case 'Car Mechanic':
        return '🔧';
      case 'Civil Engineer':
        return '🏗️';
      case 'Electrician':
        return '⚡';
      case 'Painting':
        return '🎨';
      default:
        return '🛠️';
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(job.status);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.black12,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category header
            Row(
              children: [
                Text(
                  _categoryEmoji(job.category),
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 8),
                Text(
                  job.category,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textMedium,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                // Status badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _statusLabel(job.status),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Job title
            Text(
              job.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            // Client/Provider name and date
            Row(
              children: [
                const Icon(
                  Icons.person_outline,
                  size: 14,
                  color: AppTheme.textMedium,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    job.clientName.isNotEmpty ? job.clientName : job.providerId,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textMedium,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: AppTheme.textMedium,
                ),
                const SizedBox(width: 4),
                Text(
                  DateFormat('EEE, d MMM').format(job.scheduledDate),
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textMedium,
                  ),
                ),
              ],
            ),
            // Optional actions
            if (actions != null) ...[
              const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 10),
              actions!,
            ],
          ],
        ),
      ),
    );
  }
}
