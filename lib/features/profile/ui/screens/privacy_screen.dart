import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  bool _profilePublic = true;
  bool _shareProgress = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Confidentialité", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSectionHeader("Visibilité"),
          _buildSwitch("Profil public", "Permettre aux mentors de voir ton profil", _profilePublic, (v) => setState(() => _profilePublic = v)),
          _buildSwitch("Partager ma progression", "Affecte ton classement dans la communauté", _shareProgress, (v) => setState(() => _shareProgress = v)),
          const Divider(height: 40),
          _buildSectionHeader("Données"),
          ListTile(
            title: const Text("Paramètres des cookies", style: TextStyle(fontWeight: FontWeight.w600)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            contentPadding: EdgeInsets.zero,
            onTap: () {},
          ),
          ListTile(
            title: const Text("Supprimer mon compte", style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
            trailing: const Icon(Icons.delete_outline, color: Colors.red),
            contentPadding: EdgeInsets.zero,
            onTap: () => _showDeleteDialog(),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Supprimer le compte ?"),
        content: const Text("Cette action est irréversible. Toutes vos données seront effacées."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Supprimer", style: TextStyle(color: Colors.red))),
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
