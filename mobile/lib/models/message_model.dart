class MessageModel {
  final String id;
  final String channel;
  final String fromNumber;
  final String toNumber;
  final String content;
  final String direction;
  final bool aiGenerated;
  final String? conversationId;
  final DateTime createdAt;

  MessageModel({
    required this.id,
    required this.channel,
    required this.fromNumber,
    required this.toNumber,
    required this.content,
    required this.direction,
    this.aiGenerated = false,
    this.conversationId,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] ?? '',
      channel: json['channel'] ?? 'SMS',
      fromNumber: json['fromNumber'] ?? '',
      toNumber: json['toNumber'] ?? '',
      content: json['content'] ?? '',
      direction: json['direction'] ?? 'inbound',
      aiGenerated: json['aiGenerated'] ?? false,
      conversationId: json['conversationId'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class ConversationModel {
  final String id;
  final String fromNumber;
  final String toNumber;
  final String channel;
  final String lastMessage;
  final DateTime lastMessageAt;
  final int unread;

  ConversationModel({
    required this.id,
    required this.fromNumber,
    required this.toNumber,
    required this.channel,
    required this.lastMessage,
    required this.lastMessageAt,
    this.unread = 0,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'] ?? '',
      fromNumber: json['fromNumber'] ?? '',
      toNumber: json['toNumber'] ?? '',
      channel: json['channel'] ?? 'SMS',
      lastMessage: json['lastMessage'] ?? '',
      lastMessageAt: DateTime.parse(json['lastMessageAt'] ?? DateTime.now().toIso8601String()),
      unread: json['unread'] ?? 0,
    );
  }
}
