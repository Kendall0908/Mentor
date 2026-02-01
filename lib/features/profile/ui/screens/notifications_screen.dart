import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _pushNotifications = true;
  bool _emailNotifications = false;
  bool _courseReminders = true;
  bool _mentorMessages = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Notifications", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSectionHeader("Général"),
          _buildSwitch("Notifications Push", "Recevoir des alertes sur cet appareil", _pushNotifications, (v) => setState(() => _pushNotifications = v)),
          _buildSwitch("Notifications par Email", "Recevoir des résumés par mail", _emailNotifications, (v) => setState(() => _emailNotifications = v)),
          const Divider(height: 40),
          _buildSectionHeader("Activités"),
          _buildSwitch("Rappels de cours", "Alertes pour tes sessions d'étude", _courseReminders, (v) => setState(() => _courseReminders = v)),
          _buildSwitch("Messages de mentors", "Nouvelles réponses de tes mentors", _mentorMessages, (v) => setState(() => _mentorMessages = v)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.questBlue)),
    );
  }

  Widget _buildSwitch(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.questBlue,
      contentPadding: EdgeInsets.zero,
    );
  }
}
