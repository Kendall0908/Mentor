import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mentor/features/support/data/models/academic_need.dart';
import 'package:mentor/features/support/logic/support_service.dart';
import 'package:mentor/features/auth/logic/auth_service.dart';
import '../../../../core/constants/app_colors.dart';

class AddNeedScreen extends StatefulWidget {
  const AddNeedScreen({super.key});

  @override
  State<AddNeedScreen> createState() => _AddNeedScreenState();
}

class _AddNeedScreenState extends State<AddNeedScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';
  String _category = 'Livre';
  final List<String> _categories = ['Livre', 'Certification', 'Cours', 'Tutorat'];
  
  // Contrôleurs pour les champs détaillés
  final _subjectController = TextEditingController();
  final _levelController = TextEditingController();
  final _priceController = TextEditingController();
  final _linkController = TextEditingController();
  final _platformController = TextEditingController(); // Nouveau: Plateforme (Coursera, Udemy, etc.)
  final _durationController = TextEditingController(); // Nouveau: Durée
  final _authorController = TextEditingController(); // Nouveau: Auteur/Instructeur
  final List<String> _paymentMethods = [];

  @override
  void dispose() {
    _subjectController.dispose();
    _levelController.dispose();
    _priceController.dispose();
    _linkController.dispose();
    _platformController.dispose();
    _durationController.dispose();
    _authorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          "Publier un besoin",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec icône
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.questBlue.withOpacity(0.1), Colors.white],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.questBlue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.add_circle_outline, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 15),
                    const Expanded(
                      child: Text(
                        "Partage ton besoin avec la communauté",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Section 1: Informations de base
              _buildSectionTitle("📋 Informations générales"),
              const SizedBox(height: 15),
              
              _buildTextField(
                label: "Titre de la demande",
                hint: "Ex: Besoin d'aide pour acheter une certification AWS",
                icon: Icons.title,
                validator: (value) => value == null || value.isEmpty ? "Champ requis" : null,
                onSaved: (value) => _title = value!,
              ),
              const SizedBox(height: 15),

              _buildDropdown(),
              const SizedBox(height: 15),

              _buildTextField(
                label: "Description détaillée",
                hint: "Explique pourquoi tu as besoin de cette ressource, comment elle t'aidera...",
                maxLines: 4,
                validator: (value) => value == null || value.isEmpty ? "Champ requis" : null,
                onSaved: (value) => _description = value!,
              ),
              const SizedBox(height: 30),

              // Section 2: Détails spécifiques selon la catégorie
              _buildSectionTitle("🎯 Détails de la ressource"),
              const SizedBox(height: 15),
              
              ..._buildCategorySpecificFields(),
              
              const SizedBox(height: 30),

              // Section 3: Informations de paiement
              if (_priceController.text.isNotEmpty) ...[
                _buildSectionTitle("💳 Modalités de paiement"),
                const SizedBox(height: 15),
                _buildPaymentMethodsSection(),
                const SizedBox(height: 30),
              ],

              // Bouton de soumission
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.questBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.send, color: Colors.white),
                      SizedBox(width: 10),
                      Text(
                        "Publier la demande",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    IconData? icon,
    int maxLines = 1,
    TextEditingController? controller,
    String? Function(String?)? validator,
    void Function(String?)? onSaved,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: icon != null ? Icon(icon, color: AppColors.questBlue) : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.questBlue, width: 2),
        ),
      ),
      validator: validator,
      onSaved: onSaved,
      onChanged: onChanged,
    );
  }

  Widget _buildDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonFormField<String>(
        value: _category,
        decoration: InputDecoration(
          labelText: "Type de ressource",
          prefixIcon: const Icon(Icons.category, color: AppColors.questBlue),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        items: _categories.map((cat) {
          IconData icon = Icons.book;
          if (cat == 'Certification') icon = Icons.workspace_premium;
          if (cat == 'Cours') icon = Icons.school;
          if (cat == 'Tutorat') icon = Icons.person;
          
          return DropdownMenuItem(
            value: cat,
            child: Row(
              children: [
                Icon(icon, size: 20, color: AppColors.questBlue),
                const SizedBox(width: 10),
                Text(cat),
              ],
            ),
          );
        }).toList(),
        onChanged: (value) => setState(() => _category = value!),
      ),
    );
  }

  List<Widget> _buildCategorySpecificFields() {
    List<Widget> fields = [];

    if (_category == 'Certification') {
      fields.addAll([
        _buildTextField(
          controller: _platformController,
          label: "Plateforme",
          hint: "Ex: Coursera, Udemy, LinkedIn Learning...",
          icon: Icons.cloud,
        ),
        const SizedBox(height: 15),
        _buildTextField(
          controller: _linkController,
          label: "Lien vers la certification",
          hint: "https://...",
          icon: Icons.link,
        ),
        const SizedBox(height: 15),
        _buildTextField(
          controller: _authorController,
          label: "Organisme/Instructeur",
          hint: "Ex: Google, IBM, Meta...",
          icon: Icons.business,
        ),
        const SizedBox(height: 15),
        _buildTextField(
          controller: _durationController,
          label: "Durée estimée",
          hint: "Ex: 3 mois, 40 heures...",
          icon: Icons.access_time,
        ),
        const SizedBox(height: 15),
      ]);
    }

    if (_category == 'Livre') {
      fields.addAll([
        _buildTextField(
          controller: _authorController,
          label: "Auteur du livre",
          hint: "Ex: Robert C. Martin",
          icon: Icons.person,
        ),
        const SizedBox(height: 15),
        _buildTextField(
          controller: _linkController,
          label: "Lien d'achat (optionnel)",
          hint: "Amazon, Fnac, etc.",
          icon: Icons.shopping_cart,
        ),
        const SizedBox(height: 15),
      ]);
    }

    if (_category == 'Cours' || _category == 'Tutorat') {
      fields.addAll([
        _buildTextField(
          controller: _subjectController,
          label: "Matière",
          hint: "Ex: Mathématiques, Physique...",
          icon: Icons.book,
        ),
        const SizedBox(height: 15),
        _buildTextField(
          controller: _levelController,
          label: "Niveau",
          hint: "Ex: L1, L2, Terminale...",
          icon: Icons.school,
        ),
        const SizedBox(height: 15),
      ]);
    }

    // Prix (commun à toutes les catégories)
    fields.addAll([
      _buildTextField(
        controller: _priceController,
        label: "Prix de la ressource",
        hint: "Ex: 15000 FCFA",
        icon: Icons.payments,
        onChanged: (value) => setState(() {}),
      ),
    ]);

    return fields;
  }

  Widget _buildPaymentMethodsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Moyens de paiement acceptés",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 15),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _buildPaymentChip("Mobile Money", Icons.phone_android, Colors.orange),
              _buildPaymentChip("Visa", Icons.credit_card, Colors.blue),
              _buildPaymentChip("Wave", Icons.water, Colors.purple),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentChip(String label, IconData icon, Color color) {
    final isSelected = _paymentMethods.contains(label);
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: isSelected ? Colors.white : color),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _paymentMethods.add(label);
          } else {
            _paymentMethods.remove(label);
          }
        });
      },
      selectedColor: color,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      // Fetch real user data
      final userData = await AuthService().getUserData(currentUser.uid);
      final userName = userData?['name'] ?? "Anonyme";
      final userAvatar = userData?['avatarUrl'] ?? "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200&h=200&fit=crop&q=80";

      // Create new need object
      final newNeed = AcademicNeed(
        id: '',
        title: _title,
        description: _description,
        category: _category,
        userName: userName,
        userAvatar: userAvatar,
        createdAt: DateTime.now(),
        subject: _subjectController.text.isNotEmpty ? _subjectController.text : null,
        level: _levelController.text.isNotEmpty ? _levelController.text : null,
        price: _priceController.text.isNotEmpty ? _priceController.text : null,
        link: _linkController.text.isNotEmpty ? _linkController.text : null,
      );

      _saveToFirestore(context, newNeed);
    }
  }

  Future<void> _saveToFirestore(BuildContext context, AcademicNeed need) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await SupportService.addNeed(need);
      if (mounted) {
        Navigator.pop(context); // Pop loading
        Navigator.pop(context); // Pop AddNeedScreen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 10),
                Text("Besoin publié avec succès !"),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur : $e")),
        );
      }
    }
  }
}
