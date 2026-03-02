import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:forge/models/message_model.dart';
import 'package:forge/services/firestore_service.dart';
import 'package:forge/providers/auth_provider.dart';
import 'package:forge/core/theme/app_theme.dart';

/// Lists all conversations the current user is a participant in.
class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthProvider>().uid ?? '';
    final db = FirestoreService();

    return Scaffold(
      appBar: AppBar(title: const Text('Chats')),
      backgroundColor: AppTheme.background,
      body: StreamBuilder<List<ConversationModel>>(
        stream: db.getConversations(uid),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final convos = snap.data ?? [];

          if (convos.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.chat_bubble_outline,
                      size: 56, color: AppTheme.textMedium.withOpacity(0.4)),
                  const SizedBox(height: 12),
                  const Text(
                    'No conversations yet',
                    style: TextStyle(color: AppTheme.textMedium, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Chats appear when a job is accepted.',
                    style: TextStyle(color: AppTheme.textMedium, fontSize: 13),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: convos.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, indent: 72),
            itemBuilder: (_, i) {
              final c = convos[i];

              // Find the "other" person's name
              final otherUid =
                  c.participants.firstWhere((p) => p != uid, orElse: () => '');
              final otherName =
                  c.participantNames[otherUid] ?? 'Unknown';

              return ListTile(
                leading: CircleAvatar(
                  radius: 24,
                  backgroundColor: AppTheme.primary,
                  child: Text(
                    otherName.isNotEmpty ? otherName[0].toUpperCase() : '?',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                ),
                title: Text(
                  otherName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  c.lastMessage.isNotEmpty ? c.lastMessage : 'No messages yet',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: AppTheme.textMedium, fontSize: 13),
                ),
                trailing: Text(
                  _timeAgo(c.updatedAt),
                  style: const TextStyle(
                      color: AppTheme.textMedium, fontSize: 12),
                ),
                onTap: () {
                  Navigator.of(context).pushNamed(
                    '/chat',
                    arguments: {
                      'jobId': c.jobId,
                      'otherUid': otherUid,
                      'otherName': otherName,
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }
}
