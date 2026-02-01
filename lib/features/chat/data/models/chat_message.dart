class ChatMessage {
  final String id;
  final String text;
  final bool isMe;
  final DateTime time;
  final String? userId;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isMe,
    required this.time,
    this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'isMe': isMe,
      'time': time.toIso8601String(),
      'userId': userId,
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'] ?? '',
      text: map['text'] ?? '',
      isMe: map['isMe'] ?? false,
      time: DateTime.parse(map['time']),
      userId: map['userId'],
    );
  }
}
