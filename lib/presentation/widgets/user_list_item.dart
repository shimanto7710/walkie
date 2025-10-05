import 'package:flutter/material.dart';
import '../../domain/entities/user.dart';

class UserListItem extends StatelessWidget {
  final User user;
  final VoidCallback onTap;

  const UserListItem({
    super.key,
    required this.user,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        onTap: onTap,
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: user.isOnline ? Colors.green : Colors.grey,
              child: Text(
                user.initial,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: user.isOnline ? Colors.green : Colors.grey,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
        title: Text(
          user.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user.statusText,
              style: TextStyle(
                color: user.isOnline ? Colors.green[700] : Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            if (user.lastActive.isNotEmpty)
              Text(
                'Last active: ${_formatLastActive(user.lastActive)}',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
          ],
        ),
        trailing: Icon(
          user.isOnline ? Icons.radio_button_checked : Icons.radio_button_unchecked,
          color: user.isOnline ? Colors.green : Colors.grey,
        ),
      ),
    );
  }

  String _formatLastActive(String lastActive) {
    try {
      final timestamp = int.parse(lastActive);
      final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();
      final difference = now.difference(dateTime);
      
      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else {
        return '${difference.inDays}d ago';
      }
    } catch (e) {
      return 'Unknown';
    }
  }
}
