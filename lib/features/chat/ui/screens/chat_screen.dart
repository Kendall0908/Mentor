import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/deepseek_service.dart';
import '../../data/models/chat_message.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final DeepSeekService _deepSeekService = DeepSeekService();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
    _addWelcomeMessage();
  }

  Future<void> _loadChatHistory() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('chat_history')
          .doc(user.uid)
          .collection('messages')
          .orderBy('time')
          .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          _messages.addAll(
            snapshot.docs.map((doc) => ChatMessage.fromMap(doc.data())).toList(),
          );
        });
        _scrollToBottom();
      }
    } catch (e) {
      debugPrint('Erreur chargement historique: $e');
    }
  }

  void _addWelcomeMessage() {
    if (_messages.isEmpty) {
      final welcomeMsg = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: "Bonjour ! Je suis MentOr Bot, ton assistant IA spécialisé dans l'orientation scolaire en Côte d'Ivoire 🇨🇮\n\nJe peux t'aider avec :\n• Les universités et grandes écoles ivoiriennes\n• Les concours (CAFOP, ENS, INPHB...)\n• Les bourses d'études\n• Ton orientation (séries A, C, D...)\n• Tes devoirs et révisions\n\nComment puis-je t'aider aujourd'hui ? 😊",
        isMe: false,
        time: DateTime.now(),
      );
      setState(() {
        _messages.add(welcomeMsg);
      });
    }
  }

  Future<void> _sendMessage([String? text]) async {
    final messageText = text ?? _controller.text.trim();
    if (messageText.isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: messageText,
      isMe: true,
      time: DateTime.now(),
      userId: user?.uid,
    );

    setState(() {
      _messages.add(userMessage);
      _isTyping = true;
    });

    if (text == null) _controller.clear();
    _scrollToBottom();

    // Sauvegarder le message utilisateur
    _saveMessage(userMessage);

    try {
      // Appel à l'API DeepSeek
      final response = await _deepSeekService.sendMessage(messageText);

      final aiMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: response,
        isMe: false,
        time: DateTime.now(),
      );

      if (mounted) {
        setState(() {
          _messages.add(aiMessage);
          _isTyping = false;
        });
        _scrollToBottom();
        
        // Sauvegarder la réponse IA
        _saveMessage(aiMessage);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isTyping = false;
        });
        
        final errorMessage = ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: "Désolé, une erreur s'est produite : ${e.toString()}. Vérifiez votre clé API DeepSeek dans le fichier .env",
          isMe: false,
          time: DateTime.now(),
        );
        
        setState(() {
          _messages.add(errorMessage);
        });
        _scrollToBottom();
      }
    }
  }

  Future<void> _saveMessage(ChatMessage message) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('chat_history')
          .doc(user.uid)
          .collection('messages')
          .doc(message.id)
          .set(message.toMap());
    } catch (e) {
      debugPrint('Erreur sauvegarde message: $e');
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.questBlue.withOpacity(0.1),
                  child: const Icon(Icons.smart_toy_rounded, color: AppColors.questBlue),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "MentOr Bot",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "EN LIGNE",
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            )
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.black),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Effacer l'historique"),
                  content: const Text("Voulez-vous vraiment effacer toute la conversation ?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Annuler"),
                    ),
                    TextButton(
                      onPressed: () async {
                        final user = FirebaseAuth.instance.currentUser;
                        if (user != null) {
                          await FirebaseFirestore.instance
                              .collection('chat_history')
                              .doc(user.uid)
                              .delete();
                        }
                        setState(() {
                          _messages.clear();
                          _deepSeekService.clearHistory();
                        });
                        _addWelcomeMessage();
                        Navigator.pop(context);
                      },
                      child: const Text("Effacer", style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isTyping) {
                  return _buildTypingIndicator();
                }
                final msg = _messages[index];
                return _buildMessageBubble(msg);
              },
            ),
          ),
          
          // Suggestions
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildSuggestionChip("Quelles universités en Côte d'Ivoire ?"),
                _buildSuggestionChip("Comment obtenir une bourse ?"),
                _buildSuggestionChip("Concours CAFOP 2024"),
                _buildSuggestionChip("Débouchés série C"),
              ],
            ),
          ),

          // Input field
          Container(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F2F5),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: "Posez votre question...",
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: AppColors.questBlue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send, color: Colors.white, size: 20),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(),
                const SizedBox(width: 4),
                _buildDot(delay: 200),
                const SizedBox(width: 4),
                _buildDot(delay: 400),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot({int delay = 0}) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (context, double value, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(value),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  Widget _buildSuggestionChip(String text) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0, bottom: 8),
      child: ActionChip(
        label: Text(text, style: const TextStyle(fontSize: 12, color: Colors.black87)),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        onPressed: () => _sendMessage(text),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: msg.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: msg.isMe ? AppColors.questBlue : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(msg.isMe ? 16 : 0),
                bottomRight: Radius.circular(msg.isMe ? 0 : 16),
              ),
              boxShadow: [
                if (!msg.isMe)
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
              ],
            ),
            child: Text(
              msg.text,
              style: TextStyle(
                color: msg.isMe ? Colors.white : Colors.black87,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "${msg.time.hour.toString().padLeft(2, '0')}:${msg.time.minute.toString().padLeft(2, '0')}",
            style: TextStyle(color: Colors.grey.shade400, fontSize: 10),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
