import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../app_theme.dart';
import '../services/socket_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class FarmerChatScreen extends StatefulWidget {
  final String deviceId;

  const FarmerChatScreen({super.key, required this.deviceId});

  @override
  State<FarmerChatScreen> createState() => _FarmerChatScreenState();
}

class _FarmerChatScreenState extends State<FarmerChatScreen> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool isLoading = true;
  List<dynamic> messages = [];
  final SocketService _socketService = SocketService();

  @override
  void initState() {
    super.initState();
    _fetchMessages();
    _setupSockets();
  }

  void _setupSockets() {
    _socketService.connect();
    _socketService.listen("new_message", (data) {
      // Only add messages from the officer — farmer's own messages are
      // already added optimistically when HTTP response returns, so
      // ignoring farmer-sent socket events prevents double messages.
      if (mounted &&
          data['deviceId'] == widget.deviceId &&
          data['senderRole'] != 'farmer') {
        setState(() {
          messages.add(data);
        });
        _scrollToBottom();
        _markAsRead();
      }
    });
  }

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    // Don't disconnect socket here if it's a shared singleton, but our mock implies we just unlisten.
    super.dispose();
  }

  Future<void> _fetchMessages() async {
    try {
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/api/messages/${widget.deviceId}'));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            messages = decoded['data'] ?? [];
            isLoading = false;
          });
          _scrollToBottom();
          _markAsRead();
        }
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint("Error fetching messages: \$e");
      setState(() => isLoading = false);
    }
  }

  Future<void> _markAsRead() async {
    try {
      await http.put(
        Uri.parse('${ApiConfig.baseUrl}/api/messages/${widget.deviceId}/read'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'role': 'farmer'}),
      );
    } catch (e) {
      debugPrint("Mark read error: \$e");
    }
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    
    final content = text.trim();
    _msgController.clear();

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/messages/send'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'deviceId': widget.deviceId,
          'senderId': widget.deviceId, 
          'senderRole': 'farmer',
          'content': content,
        }),
      );

      if (response.statusCode == 201) {
        final newMsg = jsonDecode(response.body)['data'];
        if (mounted) {
          setState(() {
            messages.add(newMsg);
          });
          _scrollToBottom();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to send message")));
      }
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
    return Column(
      children: [
        // Top Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.green.withOpacity(0.15), shape: BoxShape.circle),
                child: const Icon(Icons.security_rounded, color: Colors.green),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Forest Officer", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text("Assigned to ${widget.deviceId}", style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
        
        // Chat Area
        Expanded(
          child: isLoading 
              ? const Center(child: CircularProgressIndicator())
              : messages.isEmpty
                  ? Center(
                      child: Text(
                        "No messages yet.\\nSend a message to contact your assigned officer.",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(color: Colors.grey),
                      ).animate().fadeIn(),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(20),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final msg = messages[index];
                        final isMe = msg['senderRole'] == 'farmer';
                        
                        return Align(
                          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isMe ? AppColors.primary : Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(20).copyWith(
                                bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(20),
                                bottomLeft: isMe ? const Radius.circular(20) : const Radius.circular(0),
                              ),
                              border: isMe ? null : Border.all(color: Colors.grey.withOpacity(0.2)),
                              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                            ),
                            child: Text(
                              msg['content'] ?? '',
                              style: GoogleFonts.inter(
                                color: isMe ? Colors.white : AppColors.getTextPrimary(Theme.of(context).brightness),
                              ),
                            ),
                          ).animate().fadeIn().slideY(begin: 0.1),
                        );
                      },
                    ),
        ),

        // Quick Replies
        Container(
          height: 50,
          margin: const EdgeInsets.only(bottom: 8),
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _quickReplyBtn("🚨 Emergency / हेल्प", Colors.red),
              _quickReplyBtn("All fine here", Colors.green),
              _quickReplyBtn("Wild animal sighted", Colors.orange),
              _quickReplyBtn("Fence damaged", Colors.brown),
            ],
          ),
        ),

        // Input Area
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
          ),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _msgController,
                      decoration: InputDecoration(
                        hintText: "Type a message...",
                        hintStyle: GoogleFonts.inter(color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      ),
                      onSubmitted: _sendMessage,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => _sendMessage(_msgController.text),
                  child: Container(
                    padding: const EdgeInsets.all(14),
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
    );
  }

  Widget _quickReplyBtn(String text, Color color) {
    return GestureDetector(
      onTap: () => _sendMessage(text),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Text(text, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: color, fontSize: 13)),
      ),
    );
  }
}
