import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme_tokens.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../services/firestore_service.dart';
import '../services/cloudinary_service.dart';
import 'login_screen.dart';
import '../widgets/svc_snackbar.dart';

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
  bool _uploadingAttachment = false;

  // Chat identity is the Firebase Auth uid (anonymous for guests) so Firestore
  // rules can verify participants and message senders.
  String? get _authUid => FirebaseAuth.instance.currentUser?.uid;

  String get _conversationId =>
      widget.conversationId ?? 'support_${_authUid ?? 'pending'}';

  @override
  void initState() {
    super.initState();
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

  void _sendMessage({List<String> attachmentUrls = const []}) async {
    final text = _messageController.text.trim();
    if (text.isEmpty && attachmentUrls.isEmpty) return;

    final user = widget.appState.currentUser;
    final senderId = _authUid;
    if (senderId == null) return;
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
        attachmentUrls: attachmentUrls,
      );
    } catch (e) {
      if (mounted) {
        SvcSnackbar.show(context, 'Message not sent. Check your connection and try again.', type: SnackType.error);
      }
    }
  }

  void _attachImage() async {
    if (_uploadingAttachment) return;

    final user = widget.appState.currentUser;
    final senderId = _authUid;
    if (senderId == null) return;
    final senderName = user?.name ?? 'Guest User';
    final senderRole = user?.role ?? 'customer';

    setState(() => _uploadingAttachment = true);
    try {
      final url = await CloudinaryService().showImagePickerModal(
        context,
        folder: 'video_care/chat',
        title: 'Attach Photo to Chat',
      );

      if (url != null && mounted) {
        final text = _messageController.text.trim();
        _messageController.clear();

        await FirestoreService().sendChatMessage(
          conversationId: _conversationId,
          senderId: senderId,
          senderName: senderName,
          senderRole: senderRole,
          text: text,
          attachmentUrls: [url],
        );

        if (mounted) {
          SvcSnackbar.show(context, 'Photo sent to support desk!', type: SnackType.success);
        }
      }
    } catch (e) {
      if (mounted) {
        SvcSnackbar.show(context, 'Failed to upload photo to Cloudinary.', type: SnackType.error);
      }
    } finally {
      if (mounted) {
        setState(() => _uploadingAttachment = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.appState.currentUser;
    final currentUserId = _authUid ?? user?.id;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('QuickySewa Support',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                  const Icon(Icons.info_outline,
                      size: 16, color: SvcColors.primary),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Sign in to link chat history with your repair jobs and orders.',
                      style:
                          TextStyle(fontSize: 11, color: SvcColors.primaryDark),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) =>
                                LoginScreen(appState: widget.appState)),
                      );
                    },
                    style: TextButton.styleFrom(
                        padding: EdgeInsets.zero, minimumSize: Size.zero),
                    child: const Text('Sign In',
                        style: TextStyle(
                            fontSize: 11, fontWeight: FontWeight.bold)),
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
                          const Icon(Icons.chat_bubble_outline,
                              size: 36, color: SvcColors.muted),
                          const SizedBox(height: 12),
                          const Text(
                            'Connecting to live support...',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: SvcColors.ink),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${snapshot.error}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 11, color: SvcColors.muted),
                          ),
                          const SizedBox(height: 14),
                          OutlinedButton.icon(
                            onPressed: () {
                              _ensureAuth();
                              setState(() {});
                            },
                            icon: const Icon(Icons.refresh, size: 16),
                            label: const Text('Retry',
                                style: TextStyle(fontSize: 12)),
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
                            child: const Icon(Icons.chat_bubble_outline,
                                size: 26, color: SvcColors.muted),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Live Support Desk',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Send a message to speak directly with our Janakpur technical team regarding camera repairs, drone calibration, or parts availability.',
                            textAlign: TextAlign.center,
                            style:
                                TextStyle(fontSize: 13, color: SvcColors.muted),
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
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.78),
                        child: Column(
                          crossAxisAlignment: isMe
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${msg.senderName} (${msg.senderRole.toUpperCase()})',
                              style: const TextStyle(
                                  fontSize: 10, color: SvcColors.muted),
                            ),
                            const SizedBox(height: 2),
                            if (msg.attachmentUrls.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Column(
                                  crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                  children: msg.attachmentUrls.map((url) {
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 4),
                                      constraints: const BoxConstraints(maxHeight: 220, maxWidth: 260),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: SvcColors.border),
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                      child: CachedNetworkImage(
                                        imageUrl: CloudinaryService().getOptimizedUrl(url, width: 400),
                                        fit: BoxFit.cover,
                                        placeholder: (ctx, _) => Container(
                                          height: 140,
                                          color: Colors.grey.shade100,
                                          child: const Center(
                                            child: SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(strokeWidth: 2),
                                            ),
                                          ),
                                        ),
                                        errorWidget: (ctx, _, __) => Container(
                                          height: 100,
                                          color: Colors.grey.shade100,
                                          child: const Center(
                                            child: Icon(Icons.broken_image, color: Colors.grey),
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            if (msg.text.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isMe
                                      ? SvcColors.primary
                                      : const Color(0xFFF2EDE4),
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

          // Quick Technical Prompt Chips
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6),
            color: const Color(0xFFF8FAFC),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  _buildPromptChip('🔍 Check Repair Status'),
                  _buildPromptChip('📷 Lens Compatibility Question'),
                  _buildPromptChip('🚁 Drone Gimbal Calibration'),
                  _buildPromptChip('💰 Trade-In Payout Inquiry'),
                  _buildPromptChip('📍 Lab Location & Hours'),
                ],
              ),
            ),
          ),

          // Message input bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            color: SvcColors.surface,
            child: Row(
              children: [
                IconButton(
                  icon: _uploadingAttachment
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: SvcColors.primary),
                        )
                      : const Icon(Icons.camera_alt_outlined, color: SvcColors.primary),
                  tooltip: 'Attach Photo (Camera / Gallery)',
                  onPressed: _uploadingAttachment ? null : _attachImage,
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: InputDecoration(
                      hintText: user != null
                          ? 'Message as ${user.name}...'
                          : 'Ask a Janakpur lab technician...',
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
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

  Widget _buildPromptChip(String prompt) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(prompt, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: SvcColors.ink)),
        backgroundColor: Colors.white,
        side: const BorderSide(color: SvcColors.border),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        onPressed: () {
          _messageController.text = prompt;
          _sendMessage();
        },
      ),
    );
  }
}
