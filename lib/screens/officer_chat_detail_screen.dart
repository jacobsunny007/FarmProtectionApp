import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';
import '../services/message_service.dart';

class OfficerChatDetailScreen extends StatefulWidget {
  final String deviceId;
  final String farmerName;
  final String farmerPhone;

  const OfficerChatDetailScreen({
    super.key,
    required this.deviceId,
    required this.farmerName,
    required this.farmerPhone,
  });

  @override
  State<OfficerChatDetailScreen> createState() => _OfficerChatDetailScreenState();
}

class _OfficerChatDetailScreenState extends State<OfficerChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool isLoading = true;
  List<dynamic> messages = [];
  
  final List<String> quickReplies = [
    "Stay inside",
    "Help is on the way",
    "False alert?",
    "Area clear",
  ];

  @override
  void initState() {
    super.initState();
    _fetchMessages();
  }

  Future<void> _fetchMessages() async {
    final data = await MessageService.getMessages(widget.deviceId);
    if (mounted) {
      setState(() {
        messages = data;
        isLoading = false;
      });
      // Mark as read
      MessageService.markAsRead(deviceId: widget.deviceId, role: 'officer');
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final dummyMessage = {
      'content': text,
      'senderRole': 'officer',
      'createdAt': DateTime.now().toIso8601String(),
    };

    setState(() {
      messages.add(dummyMessage);
      _messageController.clear();
    });
    _scrollToBottom();

    bool success = await MessageService.sendMessage(
      deviceId: widget.deviceId,
      senderId: 'SYSTEM_OFFICER', // real app would use actual officer ID
      senderRole: 'officer',
      content: text,
    );

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to send message")));
      _fetchMessages(); // re-fetch to sync
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.farmerName, style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 18)),
            Text("Farm: ${widget.deviceId}", style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade600)),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
        actions: const [],
      ),
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final isMe = msg['senderRole'] == 'officer';
                      
                      return Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: isMe ? AppColors.primary : Colors.white,
                            borderRadius: BorderRadius.circular(20).copyWith(
                              bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(20),
                              bottomLeft: !isMe ? const Radius.circular(0) : const Radius.circular(20),
                            ),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2)),
                            ],
                          ),
                          child: Text(
                            msg['content'] ?? '',
                            style: GoogleFonts.inter(
                              color: isMe ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          
          // Quick replies
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: quickReplies.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
                  child: ActionChip(
                    label: Text(quickReplies[index]),
                    onPressed: () => _sendMessage(quickReplies[index]),
                    backgroundColor: Colors.white,
                    labelStyle: GoogleFonts.inter(fontSize: 12, color: AppColors.primary),
                    side: BorderSide(color: AppColors.primary.withOpacity(0.5)),
                  ),
                );
              },
            ),
          ),
          
          // Input area
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2))],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      style: GoogleFonts.inter(color: Colors.black87),
                      decoration: InputDecoration(
                        hintText: "Type a message...",
                        hintStyle: GoogleFonts.inter(color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      onSubmitted: _sendMessage,
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => _sendMessage(_messageController.text),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
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
