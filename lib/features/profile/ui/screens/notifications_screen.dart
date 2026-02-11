import 'package:flutter/material.dart';
import 'package:mentor/core/constants/app_colors.dart';
import 'package:mentor/features/notifications/data/notification_model.dart';
import 'package:mentor/features/notifications/logic/notification_service.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _service = NotificationService();

  bool _pushNotifications = true;
  bool _emailNotifications = false;
  bool _courseReminders = true;
  bool _mentorMessages = true;

  @override
  void initState() {
    super.initState();
    // Check for new notifications based on favorites when screen opens
    _service.checkAndGenerateNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFFAFAFA),
        appBar: AppBar(
          title: const Text(
            "Notifications",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          bottom: const TabBar(
            labelColor: AppColors.questBlue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.questBlue,
            tabs: [
              Tab(text: "Reçus"),
              Tab(text: "Paramètres"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildInboxTab(),
            _buildSettingsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildInboxTab() {
    return StreamBuilder<List<AppNotification>>(
      stream: _service.getNotificationsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notifications_off_outlined,
                    size: 80, color: Colors.grey.shade300),
                const SizedBox(height: 20),
                Text(
                  "Aucune notification pour le moment",
                  style: TextStyle(color: Colors.grey.shade500),
                ),
                const SizedBox(height: 10),
                Text(
                  "Ajoutez des filières en favoris pour recevoir des alertes !",
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                ),
              ],
            ),
          );
        }

        final notifications = snapshot.data!;

        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: notifications.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final notification = notifications[index];
            return _buildNotificationCard(notification);
          },
        );
      },
    );
  }

  Widget _buildNotificationCard(AppNotification notification) {
    return Dismissible(
      key: Key(notification.id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
       // TODO: Implement delete in service if needed, for now just UI dismiss
      },
      child: InkWell(
        onTap: () {
          _service.markAsRead(notification.id);
          _showDetailDialog(notification);
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: notification.isRead ? Colors.white : Colors.blue.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: notification.isRead ? Colors.transparent : Colors.blue.shade100,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _getIconColor(notification.type).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getIcon(notification.type),
                  color: _getIconColor(notification.type),
                  size: 20,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontWeight: notification.isRead
                                  ? FontWeight.w600
                                  : FontWeight.w800,
                              fontSize: 15,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatDate(notification.date),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSectionHeader("Général"),
        _buildSwitch("Notifications Push", "Recevoir des alertes sur cet appareil",
            _pushNotifications, (v) => setState(() => _pushNotifications = v)),
        _buildSwitch("Notifications par Email", "Recevoir des résumés par mail",
            _emailNotifications, (v) => setState(() => _emailNotifications = v)),
        const Divider(height: 40),
        _buildSectionHeader("Activités"),
        _buildSwitch("Rappels de cours", "Alertes pour tes sessions d'étude",
            _courseReminders, (v) => setState(() => _courseReminders = v)),
        _buildSwitch("Messages de mentors", "Nouvelles réponses de tes mentors",
            _mentorMessages, (v) => setState(() => _mentorMessages = v)),
      ],
    );
  }

  void _showDetailDialog(AppNotification notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
             Icon(_getIcon(notification.type), color: _getIconColor(notification.type)),
             const SizedBox(width: 10),
             Expanded(child: Text(notification.title)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Text(notification.message),
             const SizedBox(height: 20),
             if (notification.relatedProgramName != null)
               Container(
                 padding: const EdgeInsets.all(8),
                 decoration: BoxDecoration(
                   color: Colors.grey.shade100,
                   borderRadius: BorderRadius.circular(8),
                 ),
                 child: Row(
                   children: [
                     const Icon(Icons.bookmark, size: 16, color: Colors.grey),
                     const SizedBox(width: 5),
                     Text("Lié à : ${notification.relatedProgramName}", style: const TextStyle(fontSize: 12)),
                   ],
                 ),
               )
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Fermer"),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Navigate to detail
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Détails bientôt disponibles")),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.questBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Voir plus", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.questBlue),
      ),
    );
  }

  Widget _buildSwitch(String title, String subtitle, bool value,
      ValueChanged<bool> onChanged) {
    return SwitchListTile(
      title: Text(title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
      subtitle: Text(subtitle,
          style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.questBlue,
      contentPadding: EdgeInsets.zero,
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 60) {
      return "Il y a ${diff.inMinutes} min";
    } else if (diff.inHours < 24) {
      return "Il y a ${diff.inHours} h";
    } else {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }

  IconData _getIcon(NotificationType type) {
    switch (type) {
      case NotificationType.event:
        return Icons.event;
      case NotificationType.opportunity:
        return Icons.lightbulb;
      case NotificationType.contest:
        return Icons.emoji_events;
      case NotificationType.info:
        return Icons.info_outline;
    }
  }

  Color _getIconColor(NotificationType type) {
    switch (type) {
      case NotificationType.event:
        return Colors.purple;
      case NotificationType.opportunity:
        return Colors.orange;
      case NotificationType.contest:
        return Colors.amber.shade700;
      case NotificationType.info:
        return Colors.blue;
    }
  }
}

