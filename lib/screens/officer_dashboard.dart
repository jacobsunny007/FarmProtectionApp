import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../app_theme.dart';
import '../services/socket_service.dart';
import '../services/officer_service.dart';
import '../models/detection_model.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

import 'officer_alerts_screen.dart';
import 'officer_insights_screen.dart';
import 'officer_farms_screen.dart';
import 'officer_chat_list_screen.dart';
import 'officer_alert_details_screen.dart';

class OfficerDashboard extends StatefulWidget {
  final String officerId;

  const OfficerDashboard({
    super.key,
    required this.officerId,
  });

  @override
  State<OfficerDashboard> createState() => _OfficerDashboardState();
}

class _OfficerDashboardState extends State<OfficerDashboard> {
  int _selectedIndex = 0;
  String? _passedRiskLevel;
  final SocketService _socketService = SocketService();

  @override
  void initState() {
    super.initState();
    _initSocket();
  }

  void _initSocket() {
    _socketService.connect();
    _socketService.listen('new_detection', (data) {
      if (!mounted) return;
      try {
        final riskLevel = data['riskLevel'];
        if (riskLevel == 'high') {
          final animal = data['animal'] ?? 'Unknown Animal';
          final deviceId = data['deviceId'] ?? 'Unknown Device';

          ScaffoldMessenger.of(context).clearMaterialBanners();
          ScaffoldMessenger.of(context).showMaterialBanner(
            MaterialBanner(
              content: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.white)
                      .animate(onPlay: (controller) => controller.repeat())
                      .fadeIn(duration: 500.ms)
                      .then()
                      .fadeOut(duration: 500.ms),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "🚨 HIGH RISK: $animal detected at $deviceId!",
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.red.shade800,
              actions: [
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
                    setState(() {
                      _selectedIndex = 1;
                      _passedRiskLevel = 'high';
                    });
                  },
                  child: const Text('VIEW DETAILS',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                TextButton(
                  onPressed: () =>
                      ScaffoldMessenger.of(context).hideCurrentMaterialBanner(),
                  child: const Text('DISMISS',
                      style: TextStyle(color: Colors.white70)),
                ),
              ],
            ),
          );
        }
      } catch (e) {
        debugPrint("Error parsing detection for notification: $e");
      }
    });
  }

  @override
  void dispose() {
    _socketService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      _OfficerHomeTab(
        officerId: widget.officerId,
        onNavigate: (index, {String? riskLevel}) {
          setState(() {
            _selectedIndex = index;
            _passedRiskLevel = riskLevel;
          });
        },
      ),
      OfficerAlertsScreen(initialRiskLevel: _passedRiskLevel),
      const OfficerInsightsScreen(),
      const OfficerFarmsScreen(),
      const OfficerChatListScreen(),
    ];

    final List<String> _titles = [
      "Monitoring Dashboard",
      "Alerts System",
      "AI Insights",
      "Farm Management",
      "Farmer Communication",
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _selectedIndex != 0
          ? AppBar(
              title: Text(
                _titles[_selectedIndex],
                style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
              ),
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              elevation: 0,
              foregroundColor:
                  AppColors.getTextPrimary(Theme.of(context).brightness),
            )
          : null,
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: NavigationBar(
            selectedIndex: _selectedIndex,
            height: 70,
            onDestinationSelected: (index) => setState(() => _selectedIndex = index),
            backgroundColor: Theme.of(context).cardColor,
            elevation: 0,
            indicatorColor: AppColors.primary.withOpacity(0.15),
            labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard_rounded, color: AppColors.primary),
                label: 'Dashboard',
              ),
              NavigationDestination(
                icon: Icon(Icons.notifications_none_rounded),
                selectedIcon: Icon(Icons.notifications_active_rounded, color: AppColors.primary),
                label: 'Alerts',
              ),
              NavigationDestination(
                icon: Icon(Icons.insights_outlined),
                selectedIcon: Icon(Icons.insights_rounded, color: AppColors.primary),
                label: 'Insights',
              ),
              NavigationDestination(
                icon: Icon(Icons.landscape_outlined),
                selectedIcon: Icon(Icons.landscape_rounded, color: AppColors.primary),
                label: 'Farms',
              ),
              NavigationDestination(
                icon: Icon(Icons.chat_bubble_outline_rounded),
                selectedIcon: Icon(Icons.chat_bubble_rounded, color: AppColors.primary),
                label: 'Chat',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Dashboard Home Tab — Summary cards only, no Quick Actions, no Recent Alerts
// ─────────────────────────────────────────────────────────────────────────────

class _OfficerHomeTab extends StatefulWidget {
  final String officerId;
  final void Function(int index, {String? riskLevel}) onNavigate;
  const _OfficerHomeTab({required this.officerId, required this.onNavigate});

  @override
  State<_OfficerHomeTab> createState() => _OfficerHomeTabState();
}

class _OfficerHomeTabState extends State<_OfficerHomeTab> {
  bool isLoadingStats = true;
  bool isLoadingCritical = true;
  bool isLoadingNotifications = true;
  bool hasUnreadNotifications = false;
  List<Detection> criticalAlerts = [];
  List<AppNotification> notificationsList = [];

  Map<String, dynamic> stats = {
    'totalAlertsToday': 0,
    'highRiskAlerts': 0,
    'activeFarms': 0,
    'resolvedAlerts': 0,
    'pendingAlerts': 0,
    'investigatingAlerts': 0,
  };

  @override
  void initState() {
    super.initState();
    _fetchStats();
    _fetchCriticalAlerts();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    try {
      final notifs = await NotificationService.getNotifications("all");
      if (mounted) {
        setState(() {
          notificationsList = notifs;
          hasUnreadNotifications = notifs.any((n) => !n.read);
          isLoadingNotifications = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoadingNotifications = false);
      }
    }
  }

  Future<void> _fetchStats() async {
    final data = await OfficerService.getDashboardStats();
    if (mounted && data != null) {
      setState(() {
        stats = data;
        isLoadingStats = false;
      });
    } else if (mounted) {
      setState(() => isLoadingStats = false);
    }
  }

  Future<void> _fetchCriticalAlerts() async {
    final data = await OfficerService.getHighRiskAlerts(limit: 2);
    if (mounted) {
      setState(() {
        criticalAlerts = data;
        isLoadingCritical = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _fetchStats,
      child: CustomScrollView(
        slivers: [
          // ── Hero Header ──
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              decoration: const BoxDecoration(
                gradient: AppColors.heroGradient,
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(32)),
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    // Top row with notifications & logout
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Monitoring Dashboard",
                          style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white60),
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: _showNotifications,
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(12)),
                                child: Stack(
                                  children: [
                                    const Icon(Icons.notifications_none_rounded,
                                        size: 20, color: Colors.white),
                                    if (hasUnreadNotifications)
                                      Positioned(
                                        right: 0,
                                        top: 0,
                                        child: Container(
                                          width: 8,
                                          height: 8,
                                          decoration: const BoxDecoration(
                                            color: Colors.redAccent,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushNamedAndRemoveUntil(
                                    context, '/login', (route) => false);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(12)),
                                child: const Icon(Icons.logout_rounded,
                                    size: 20, color: Colors.white54),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16)),
                          child: const Icon(Icons.shield_rounded,
                              size: 28, color: Colors.white),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Officer: ${widget.officerId}",
                              style: GoogleFonts.outfit(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "Wildlife Protection Officer",
                              style: GoogleFonts.inter(
                                  fontSize: 13, color: Colors.white54),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // ── Status Stat Cards ──
                    if (isLoadingStats)
                      const Center(
                          child:
                              CircularProgressIndicator(color: Colors.white60))
                    else
                      Column(
                        children: [
                          Row(
                            children: [
                              _statCard(
                                icon: Icons.pending_actions_rounded,
                                value: stats['pendingAlerts'].toString(),
                                label: "Pending",
                                color: Colors.orange,
                              ),
                              const SizedBox(width: 12),
                              _statCard(
                                icon: Icons.manage_search_rounded,
                                value: stats['investigatingAlerts'].toString(),
                                label: "Investigating",
                                color: Colors.blue,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _statCard(
                                icon: Icons.notifications_active_rounded,
                                value: stats['totalAlertsToday'].toString(),
                                label: "Today",
                                color: Colors.purpleAccent,
                              ),
                              const SizedBox(width: 12),
                              _statCard(
                                icon: Icons.task_alt_rounded,
                                value: stats['resolvedAlerts'].toString(),
                                label: "Resolved",
                                color: Colors.greenAccent,
                              ),
                            ],
                          ),
                        ],
                      ).animate().fadeIn().slideY(begin: 0.1),
                  ],
                ),
              ),
            ),
          ),

          // ── Critical Alerts Preview ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                                color: Colors.red, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Critical Alerts",
                            style: GoogleFonts.outfit(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.getTextPrimary(
                                  Theme.of(context).brightness),
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () => widget.onNavigate(1, riskLevel: 'high'),
                        child: Text("View All",
                            style: GoogleFonts.inter(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (isLoadingCritical)
                    const Center(child: CircularProgressIndicator())
                  else if (criticalAlerts.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.withOpacity(0.1))),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, color: Colors.green),
                          const SizedBox(width: 12),
                          Text("No critical alerts right now",
                              style: GoogleFonts.inter(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    )
                  else
                    ...criticalAlerts.map((alert) => _criticalAlertCard(alert)),
                ],
              ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.1),
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
        ],
      ),
    );
  }

  void _showNotifications() {
    if (hasUnreadNotifications) {
      NotificationService.markAllAsRead("all");
      setState(() => hasUnreadNotifications = false);
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Recent Notifications",
                  style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.getTextPrimary(Theme.of(context).brightness)),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.grey),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: isLoadingNotifications
                  ? const Center(child: CircularProgressIndicator())
                  : notificationsList.isEmpty
                      ? Center(
                          child: Text("No new notifications",
                              style: GoogleFonts.inter(color: Colors.grey)))
                      : ListView.builder(
                          itemCount: notificationsList.length,
                          itemBuilder: (context, index) {
                            final notif = notificationsList[index];

                            IconData icon;
                            Color color;
                            switch (notif.type) {
                              case 'detection':
                              case 'alert_status':
                                icon = Icons.warning_amber_rounded;
                                color = Colors.red;
                                break;
                              case 'camera':
                                icon = Icons.camera_alt_rounded;
                                color = Colors.green;
                                break;
                              case 'officer_note':
                                icon = Icons.note_alt_rounded;
                                color = Colors.blue;
                                break;
                              default:
                                icon = Icons.info_outline_rounded;
                                color = Colors.blue;
                            }

                            final date = DateTime.parse(notif.createdAt).toLocal();
                            final now = DateTime.now();
                            final diff = now.difference(date);
                            String timeStr;
                            if (diff.inMinutes < 60) {
                              timeStr = "${diff.inMinutes}m ago";
                            } else if (diff.inHours < 24) {
                              timeStr = "${diff.inHours}h ago";
                            } else {
                              timeStr = "${diff.inDays}d ago";
                            }

                            return _notificationTile(icon, notif.title, notif.message, timeStr, color);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _notificationTile(IconData icon, String title, String msg, String time, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: AppColors.getTextPrimary(Theme.of(context).brightness))),
                const SizedBox(height: 4),
                Text(msg, style: GoogleFonts.inter(fontSize: 13, color: Colors.grey)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(time, style: GoogleFonts.inter(fontSize: 11, color: Colors.grey.shade400)),
        ],
      ),
    );
  }

  Widget _criticalAlertCard(Detection alert) {
    String formatTimestamp(String timestamp) {
      try {
        final date = DateTime.parse(timestamp).toLocal();
        return "${date.day}/${date.month} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
      } catch (e) {
        return timestamp;
      }
    }

    return Dismissible(
      key: Key(alert.id),
      direction: DismissDirection.startToEnd,
      onDismissed: (direction) {
        setState(() {
          criticalAlerts.removeWhere((item) => item.id == alert.id);
        });
        OfficerService.deleteAlert(alert.id);
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Alert deleted permanently')),
        );
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerLeft,
        child: const Icon(Icons.delete_rounded, color: Colors.white, size: 28),
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => OfficerAlertDetailsScreen(alert: alert)),
          ).then((_) => _fetchCriticalAlerts());
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.red.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.warning_amber_rounded,
                    color: Colors.red, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alert.animal.toUpperCase(),
                      style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: AppColors.getTextPrimary(
                              Theme.of(context).brightness)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "${alert.deviceId}  •  ${formatTimestamp(alert.timestamp)}",
                      style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }



  Widget _statCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.black.withOpacity(0.05)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 10),
              Text(value,
                  style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87)),
              const SizedBox(height: 2),
              Text(label,
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.black87),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
