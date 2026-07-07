import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../models/message_model.dart';
import '../../core/utils/formatters.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final ApiService _api = ApiService();
  List<ConversationModel> _conversations = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    try {
      final data = await _api.getConversations();
      if (mounted) {
        setState(() {
          _conversations = data.map((e) => ConversationModel.fromJson(e)).toList();
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _conversations.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.message_outlined, size: 64, color: AppTheme.textMuted),
                      SizedBox(height: 16),
                      Text('No messages yet', style: TextStyle(color: AppTheme.textSecondary)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadConversations,
                  child: ListView.builder(
                    itemCount: _conversations.length,
                    itemBuilder: (context, index) {
                      final conv = _conversations[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: conv.unread > 0
                                ? AppTheme.primaryColor.withOpacity(0.2)
                                : AppTheme.cardColor,
                            child: Text(
                              conv.fromNumber.isNotEmpty ? conv.fromNumber.substring(0, 1) : '?',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  Formatters.formatPhone(conv.fromNumber),
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ),
                              Text(
                                Formatters.timeAgo(conv.lastMessageAt),
                                style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                              ),
                            ],
                          ),
                          subtitle: Text(
                            conv.lastMessage,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: conv.unread > 0 ? AppTheme.textPrimary : AppTheme.textSecondary,
                              fontWeight: conv.unread > 0 ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                          trailing: conv.unread > 0
                              ? Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: AppTheme.primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '${conv.unread}',
                                    style: const TextStyle(fontSize: 11, color: Colors.white),
                                  ),
                                )
                              : const Icon(Icons.chevron_right, color: AppTheme.textMuted),
                          onTap: () => _openConversation(conv),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  void _openConversation(ConversationModel conv) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _ConversationDetailScreen(conversationId: conv.id, phoneNumber: conv.fromNumber),
      ),
    );
  }
}

class _ConversationDetailScreen extends StatefulWidget {
  final String conversationId;
  final String phoneNumber;
  const _ConversationDetailScreen({required this.conversationId, required this.phoneNumber});

  @override
  State<_ConversationDetailScreen> createState() => _ConversationDetailScreenState();
}

class _ConversationDetailScreenState extends State<_ConversationDetailScreen> {
  final ApiService _api = ApiService();
  final _messageController = TextEditingController();
  List<MessageModel> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    try {
      final data = await _api.getConversationMessages(widget.conversationId);
      if (mounted) {
        setState(() {
          _messages = data.map((e) => MessageModel.fromJson(e)).toList();
        });
      }
    } catch (_) {}
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    _messageController.clear();
    try {
      await _api.sendMessage({
        'toNumber': widget.phoneNumber,
        'content': content,
        'channel': 'SMS',
        'conversationId': widget.conversationId,
      });
      _loadMessages();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Formatters.formatPhone(widget.phoneNumber)),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isOutbound = msg.direction == 'outbound';

                return Align(
                  alignment: isOutbound ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: isOutbound ? AppTheme.primaryColor : AppTheme.cardColor,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: isOutbound ? const Radius.circular(16) : Radius.zero,
                        bottomRight: isOutbound ? Radius.zero : const Radius.circular(16),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(msg.content, style: const TextStyle(color: Colors.white)),
                        const SizedBox(height: 4),
                        Text(
                          Formatters.timeAgo(msg.createdAt),
                          style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.7)),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: AppTheme.surfaceColor,
              border: Border(top: BorderSide(color: AppTheme.borderColor)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: InputBorder.none,
                      filled: false,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: AppTheme.primaryColor),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
