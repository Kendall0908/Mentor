import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart'
    show FilePicker, FileType, PlatformFile;
import '../../../../core/constants/app_colors.dart';
import '../../../auth/logic/auth_service.dart';
import '../../../auth/ui/widgets/custom_button.dart';
import '../../../../core/services/cloudinary_service.dart';
import '../../../../core/services/grade_extractor_service.dart';
import 'grades_recap_screen.dart';

class BulletinUploadScreen extends StatefulWidget {
  final String currentClass;
  final List<String> classesUpTo;

  const BulletinUploadScreen({
    super.key,
    required this.currentClass,
    required this.classesUpTo,
  });

  @override
  State<BulletinUploadScreen> createState() => _BulletinUploadScreenState();
}

class _BulletinUploadScreenState extends State<BulletinUploadScreen> {
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final AuthService _authService = AuthService();
  final GradeExtractorService _gradeExtractorService = GradeExtractorService();

  static const List<String> _trimesters = ['Trimestre 1', 'Trimestre 2', 'Trimestre 3'];

  // Map: className -> trimester -> PlatformFile?
  final Map<String, Map<String, PlatformFile?>> _uploadedFiles = {};
  // Map: className -> trimester -> cloudinaryUrl
  final Map<String, Map<String, String>> _uploadedUrls = {};
  
  final Set<String> _uploadingKeys = {};
  // OCR + AI: statut de traitement et résultats
  final Set<String> _ocrProcessingKeys = {};
  // Résultats OCR+AI : className -> { subject -> average }
  final Map<String, Map<String, double>> _extractedGrades = {};

  final int _maxFileSize = 5 * 1024 * 1024; // 5 MB
  final List<String> _allowedExtensions = ['pdf', 'png', 'jpg', 'jpeg'];

  // Track which classes are expanded
  final Set<String> _expandedClasses = {};

  @override
  void initState() {
    super.initState();
    // Initialize the maps for each class
    for (var className in widget.classesUpTo) {
      _uploadedFiles[className] = {};
      _uploadedUrls[className] = {};
      for (var trimester in _trimesters) {
        _uploadedFiles[className]![trimester] = null;
        _uploadedUrls[className]![trimester] = '';
      }
    }
    // Expand the current (last) class by default
    if (widget.classesUpTo.isNotEmpty) {
      _expandedClasses.add(widget.classesUpTo.last);
    }
  }

  Future<void> _pickFileFor(String className, String trimester) async {
    final key = '$className|$trimester';
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: _allowedExtensions,
        allowMultiple: false,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        if (file.size > _maxFileSize) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Le fichier dépasse la limite de 5 Mo")),
            );
          }
          return;
        }

        setState(() => _uploadingKeys.add(key));

        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid == null) throw Exception("Utilisateur non connecté");

        final response = await _cloudinaryService.uploadFile(file);

        if (response != null && response.containsKey('secure_url')) {
          final String url = response['secure_url'];

          // Sauvegarder dans Firestore
          await _authService.updateUserData(uid, {
            'bulletins.$className.$trimester': {
              'fileName': file.name,
              'fileType': file.extension ?? 'unknown',
              'fileSize': response['bytes'] ?? file.size,
              'cloudinaryUrl': url,
              'publicId': response['public_id'],
              'uploadDate': DateTime.now().toIso8601String(),
            }
          });

          if (mounted) {
            setState(() {
              _uploadedFiles[className]![trimester] = file;
              _uploadedUrls[className]![trimester] = url;
            });
          }

          // Lancer l'extraction des notes par IA (Gemini) en arrière-plan
          _runGeminiExtraction(file, className, trimester);
        }
      }
    } catch (e) {
      debugPrint("Erreur upload: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur : $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _uploadingKeys.remove(key));
    }
  }

  /// Extrait les notes via Gemini
  Future<void> _runGeminiExtraction(
      PlatformFile file, String className, String trimester) async {
    final key = '$className|$trimester';
    try {
      if (mounted) setState(() => _ocrProcessingKeys.add(key));

      // Extraction directe via Gemini (OCR + Analyse)
      final grades = await _gradeExtractorService.extractGrades(file, className);

      if (grades.isNotEmpty && mounted) {
        setState(() {
          _extractedGrades[className] ??= {};
          _extractedGrades[className]!.addAll(grades);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '✅ ${grades.length} moyennes extraites par l\'IA pour $className'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Gemini extraction error ($className $trimester): $e');
    } finally {
      if (mounted) setState(() => _ocrProcessingKeys.remove(key));
    }
  }

  void _removeFile(String className, String trimester) {
    setState(() {
      _uploadedFiles[className]![trimester] = null;
      _uploadedUrls[className]![trimester] = '';
    });
  }

  int get _totalUploaded {
    int count = 0;
    for (var classFiles in _uploadedFiles.values) {
      for (var file in classFiles.values) {
        if (file != null) count++;
      }
    }
    return count;
  }

  int get _totalSlots => widget.classesUpTo.length * _trimesters.length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: const [
            Text(
              "MentOr",
              style: TextStyle(
                color: AppColors.questBlue,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              "BULLETINS SCOLAIRES",
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.questBlue.withOpacity(0.1),
                          AppColors.questBlue.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.questBlue.withOpacity(0.15),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.questBlue.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.upload_file_rounded,
                            color: AppColors.questBlue,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Uploadez vos bulletins",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "De la 6ème à la ${widget.currentClass} • Par trimestre",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Progress
                              Row(
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: LinearProgressIndicator(
                                        value: _totalSlots > 0
                                            ? _totalUploaded / _totalSlots
                                            : 0,
                                        backgroundColor: Colors.grey.shade200,
                                        valueColor:
                                            const AlwaysStoppedAnimation<Color>(
                                                AppColors.questBlue),
                                        minHeight: 6,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    "$_totalUploaded/$_totalSlots",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: AppColors.questBlue,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Classes accordion list
                  ...widget.classesUpTo.reversed.map((className) =>
                      _buildClassAccordion(className)),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Bottom actions
          Container(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              children: [
                CustomButton(
                  text: _ocrProcessingKeys.isNotEmpty
                      ? "Analyse en cours..."
                      : "Continuer",
                  onPressed: _ocrProcessingKeys.isNotEmpty
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GradesRecapScreen(
                                classes: widget.classesUpTo,
                                extractedGrades: _extractedGrades.isNotEmpty
                                    ? _extractedGrades
                                    : null,
                              ),
                            ),
                          );
                        },
                  type: ButtonType.primary,
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GradesRecapScreen(
                          classes: widget.classesUpTo,
                        ),
                      ),
                    );
                  },
                  child: Text(
                    "Passer cette étape",
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassAccordion(String className) {
    final bool isExpanded = _expandedClasses.contains(className);
    final classFiles = _uploadedFiles[className] ?? {};
    final int uploadedForClass =
        classFiles.values.where((f) => f != null).length;
    final bool isComplete = uploadedForClass == _trimesters.length;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isComplete
              ? Colors.green.withOpacity(0.3)
              : isExpanded
                  ? AppColors.questBlue.withOpacity(0.3)
                  : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: isExpanded
                ? AppColors.questBlue.withOpacity(0.08)
                : Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header row
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedClasses.remove(className);
                } else {
                  _expandedClasses.add(className);
                }
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: isComplete
                          ? Colors.green.withOpacity(0.1)
                          : AppColors.questBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Icon(
                        isComplete
                            ? Icons.check_circle_rounded
                            : Icons.folder_rounded,
                        color: isComplete ? Colors.green : AppColors.questBlue,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          className,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          "$uploadedForClass/${_trimesters.length} bulletins",
                          style: TextStyle(
                            fontSize: 12,
                            color: isComplete
                                ? Colors.green
                                : Colors.grey.shade500,
                            fontWeight: isComplete ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    duration: const Duration(milliseconds: 200),
                    turns: isExpanded ? 0.5 : 0,
                    child: Icon(
                      Icons.expand_more_rounded,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Expanded content: trimesters
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState:
                isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: _trimesters
                    .map((t) => _buildTrimesterRow(className, t))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrimesterRow(String className, String trimester) {
    final file = _uploadedFiles[className]?[trimester];
    final key = '$className|$trimester';
    final isUploading = _uploadingKeys.contains(key);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: file != null
            ? Colors.green.withOpacity(0.05)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: file != null
              ? Colors.green.withOpacity(0.2)
              : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          // Trimester icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: file != null
                  ? Colors.green.withOpacity(0.1)
                  : AppColors.questBlue.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                "T${_trimesters.indexOf(trimester) + 1}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: file != null ? Colors.green : AppColors.questBlue,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Trimester name + file info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trimester,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Colors.black,
                  ),
                ),
                if (file != null)
                  Text(
                    file.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                  ),
              ],
            ),
          ),

          // Action button
          if (isUploading)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.questBlue,
              ),
            )
          else if (file != null)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 20),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () => _removeFile(className, trimester),
                  child: Icon(Icons.close, color: Colors.grey.shade400, size: 18),
                ),
              ],
            )
          else
            GestureDetector(
              onTap: () => _pickFileFor(className, trimester),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.questBlue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, color: Colors.white, size: 14),
                    SizedBox(width: 4),
                    Text(
                      "Ajouter",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
