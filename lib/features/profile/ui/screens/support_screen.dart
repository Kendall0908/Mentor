import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Aide & Support", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildHeader(),
          const SizedBox(height: 30),
          _buildSectionHeader("Besoin d'aide ?"),
          _buildSupportItem(Icons.help_outline, "Centre d'aide / FAQ", "Retrouvez les réponses aux questions fréquentes"),
          _buildSupportItem(Icons.email_outlined, "Contacter le support", "Réponse sous 24h par email"),
          _buildSupportItem(Icons.chat_bubble_outline, "Chat en direct", "Discuter avec un conseiller"),
          const Divider(height: 40),
          _buildSectionHeader("À propos"),
          _buildSupportItem(Icons.info_outline, "Conditions d'utilisation", ""),
          _buildSupportItem(Icons.security, "Politique de confidentialité", ""),
          const SizedBox(height: 20),
          const Center(
            child: Text("Version 1.0.0", style: TextStyle(color: Colors.grey, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        children: [
          Icon(Icons.support_agent, size: 50, color: AppColors.questBlue),
          SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Comment pouvons-nous vous aider ?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                SizedBox(height: 5),
                Text("Notre équipe est là pour vous accompagner.", style: TextStyle(fontSize: 13, color: Colors.black54)),
              ],
            ),
          )
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

  Widget _buildSupportItem(IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Icon(icon, color: AppColors.questBlue),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: subtitle.isNotEmpty ? Text(subtitle, style: const TextStyle(fontSize: 12)) : null,
      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      contentPadding: EdgeInsets.zero,
      onTap: () {},
    );
  }
}
