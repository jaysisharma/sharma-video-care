import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme_tokens.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../services/firestore_service.dart';
import 'login_screen.dart';

class ChatScreen extends StatefulWidget {
  final AppState appState;
  final String? conversationId;
  final String? jobTitle;

  const ChatScreen({
    super.key,
    required this.appState,
    this.conversationId,
    this.jobTitle,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  late String _conversationId;

  @override
  void initState() {
    super.initState();
    final user = widget.appState.currentUser;
    // Link chat to specific job or customer's support room
    _conversationId = widget.conversationId ??
        (user != null ? 'support_${user.id}' : 'general_support');
    _ensureAuth();
  }

  void _ensureAuth() async {
    if (FirebaseAuth.instance.currentUser == null) {
      try {
        await FirebaseAuth.instance.signInAnonymously();
        if (mounted) setState(() {});
      } catch (e) {
        debugPrint('Anonymous auth skipped: $e');
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final user = widget.appState.currentUser;
    final senderId = user?.id ?? 'guest';
    final senderName = user?.name ?? 'Guest User';
    final senderRole = user?.role ?? 'customer';

    _messageController.clear();

    try {
      await FirestoreService().sendChatMessage(
        conversationId: _conversationId,
        senderId: senderId,
        senderName: senderName,
        senderRole: senderRole,
        text: text,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: SvcColors.danger, content: Text('Error sending message: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.appState.currentUser;
    final currentUserId = user?.id ?? 'guest';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('SVC Support & Helpdesk', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(
              widget.jobTitle != null
                  ? 'Linked: ${widget.jobTitle}'
                  : 'Janakpur Lab • 10:00 AM – 7:00 PM NPT',
              style: const TextStyle(fontSize: 11, color: SvcColors.muted),
            ),
          ],
        ),
        backgroundColor: SvcColors.surface,
        elevation: 0.5,
      ),
      body: Column(
        children: [
          // Banner for guests
          if (user == null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              color: SvcColors.primarySoft,
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 16, color: SvcColors.primary),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Sign in to link chat history with your repair jobs and orders.',
                      style: TextStyle(fontSize: 11, color: SvcColors.primaryDark),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => LoginScreen(appState: widget.appState)),
                      );
                    },
                    style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                    child: const Text('Sign In', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),

          // Streamed messages list
          Expanded(
            child: StreamBuilder<List<ChatMessageModel>>(
              stream: FirestoreService().streamMessages(_conversationId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.chat_bubble_outline, size: 36, color: SvcColors.muted),
                          const SizedBox(height: 12),
                          const Text(
                            'Connecting to live support...',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SvcColors.ink),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${snapshot.error}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 11, color: SvcColors.muted),
                          ),
                          const SizedBox(height: 14),
                          OutlinedButton.icon(
                            onPressed: () {
                              _ensureAuth();
                              setState(() {});
                            },
                            icon: const Icon(Icons.refresh, size: 16),
                            label: const Text('Retry', style: TextStyle(fontSize: 12)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: SvcColors.primary,
                              side: const BorderSide(color: SvcColors.border),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final messages = snapshot.data ?? [];

                if (messages.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: SvcColors.canvas,
                              shape: BoxShape.circle,
                              border: Border.all(color: SvcColors.border),
                            ),
                            child: const Icon(Icons.chat_bubble_outline, size: 26, color: SvcColors.muted),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Live Support Desk',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Send a message to speak directly with our Janakpur technical team regarding camera repairs, drone calibration, or parts availability.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, color: SvcColors.muted),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg.senderId == currentUserId;

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
                        child: Column(
                          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${msg.senderName} (${msg.senderRole.toUpperCase()})',
                              style: const TextStyle(fontSize: 10, color: SvcColors.muted),
                            ),
                            const SizedBox(height: 2),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: isMe ? SvcColors.primary : const Color(0xFFF2EDE4),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                msg.text,
                                style: TextStyle(
                                  color: isMe ? Colors.white : SvcColors.ink,
                                  fontSize: 13,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Message input bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: SvcColors.surface,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: InputDecoration(
                      hintText: user != null ? 'Message as ${user.name}...' : 'Type inquiry for support...',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: SvcColors.primary),
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
