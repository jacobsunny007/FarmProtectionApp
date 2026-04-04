import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../app_theme.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

class FarmerNotificationsScreen extends StatefulWidget {
  final String deviceId;

  const FarmerNotificationsScreen({super.key, required this.deviceId});

  @override
  State<FarmerNotificationsScreen> createState() =>
      _FarmerNotificationsScreenState();
}

class _FarmerNotificationsScreenState
    extends State<FarmerNotificationsScreen> {
  bool isLoading = true;
  // Only unread notifications shown — read ones disappear
  List<AppNotification> notifications = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => isLoading = true);
    try {
      final data =
          await NotificationService.getNotifications(widget.deviceId);
      if (mounted) {
        setState(() {
          // Only show unread notifications
          notifications = data.where((n) => !n.read).toList();
          isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  /// Mark a single notification as read and remove it from the visible list
  Future<void> _markOneAsRead(String id, int index) async {
    await NotificationService.markAsRead(id);
    if (mounted) {
      setState(() {
        notifications.removeAt(index);
      });
    }
  }

  Future<void> _markAllAsRead() async {
    await NotificationService.markAllAsRead(widget.deviceId);
    if (mounted) {
      setState(() {
        notifications.clear();
      });
    }
  }

  /// Classify notification type visually
  /// Types: 'chat', 'detection', 'alert', 'officer_note', 'investigating', 'resolved'
  IconData _iconFor(String type) {
    switch (type) {
      case 'chat':
        return Icons.chat_bubble_rounded;
      case 'officer_note':
        return Icons.sticky_note_2_rounded;
      case 'investigating':
        return Icons.manage_search_rounded;
      case 'resolved':
        return Icons.task_alt_rounded;
      case 'detection':
      case 'alert':
      default:
        return Icons.warning_amber_rounded;
    }
  }

  Color _colorFor(String type) {
    switch (type) {
      case 'chat':
        return Colors.blue;
      case 'officer_note':
        return Colors.teal;
      case 'investigating':
        return Colors.orange;
      case 'resolved':
        return Colors.green;
      case 'detection':
      case 'alert':
      default:
        return Colors.red;
    }
  }

  String _labelFor(String type) {
    switch (type) {
      case 'chat':
        return 'Chat';
      case 'officer_note':
        return 'Alert Note from Officer';
      case 'investigating':
        return 'Alert';
      case 'resolved':
        return 'Alert';
      case 'detection':
      case 'alert':
      default:
        return 'Alert';
    }
  }

  String _formatTime(String raw) {
    try {
      final dt = DateTime.parse(raw).toLocal();
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Notifications',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor:
            AppColors.getTextPrimary(Theme.of(context).brightness),
        elevation: 0,
        actions: [
          if (notifications.isNotEmpty)
            TextButton.icon(
              onPressed: _markAllAsRead,
              icon: const Icon(Icons.done_all_rounded, size: 18),
              label: Text('Clear all',
                  style: GoogleFonts.inter(fontSize: 13)),
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.notifications_none_rounded,
                          size: 72, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text('All caught up!',
                          style: GoogleFonts.outfit(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey)),
                      const SizedBox(height: 8),
                      Text(
                        'No unread notifications.\nOfficer updates will appear here.',
                        style: GoogleFonts.inter(
                            color: Colors.grey, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ).animate().fadeIn(),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final n = notifications[index];
                      final color = _colorFor(n.type);
                      final icon = _iconFor(n.type);
                      final categoryLabel = _labelFor(n.type);

                      return GestureDetector(
                        onTap: () => _markOneAsRead(n.id, index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 5),
                          decoration: BoxDecoration(
                            color: isDark
                                ? color.withOpacity(0.08)
                                : color.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: color.withOpacity(0.25),
                            ),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3)),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Icon
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: color.withOpacity(0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child:
                                      Icon(icon, color: color, size: 22),
                                ),
                                const SizedBox(width: 14),
                                // Text
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Category tag
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        margin: const EdgeInsets.only(bottom: 4),
                                        decoration: BoxDecoration(
                                          color: color.withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          categoryLabel,
                                          style: GoogleFonts.inter(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: color,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              n.title,
                                              style: GoogleFonts.outfit(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 15,
                                                color:
                                                    AppColors.getTextPrimary(
                                                        Theme.of(context)
                                                            .brightness),
                                              ),
                                              maxLines: 1,
                                              overflow:
                                                  TextOverflow.ellipsis,
                                            ),
                                          ),
                                          // Unread dot
                                          Container(
                                            width: 8,
                                            height: 8,
                                            margin: const EdgeInsets.only(left: 6),
                                            decoration: BoxDecoration(
                                              color: color,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        n.message,
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          color: AppColors.getTextSecondary(
                                              Theme.of(context).brightness),
                                          height: 1.4,
                                        ),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Text(
                                            _formatTime(n.createdAt),
                                            style: GoogleFonts.inter(
                                                fontSize: 11,
                                                color: Colors.grey),
                                          ),
                                          const Spacer(),
                                          Text(
                                            'Tap to dismiss',
                                            style: GoogleFonts.inter(
                                                fontSize: 11,
                                                color: color.withOpacity(0.7),
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ).animate().fadeIn(
                            delay:
                                Duration(milliseconds: index * 40)),
                      );
                    },
                  ),
                ),
    );
  }
}
