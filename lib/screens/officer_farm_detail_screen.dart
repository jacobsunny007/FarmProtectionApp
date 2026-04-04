import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../app_theme.dart';
import '../services/officer_service.dart';
import 'officer_chat_detail_screen.dart';
import 'officer_map_screen.dart';

class OfficerFarmDetailScreen extends StatefulWidget {
  final Map<String, dynamic> farm;

  const OfficerFarmDetailScreen({super.key, required this.farm});

  @override
  State<OfficerFarmDetailScreen> createState() =>
      _OfficerFarmDetailScreenState();
}

class _OfficerFarmDetailScreenState extends State<OfficerFarmDetailScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.farm['name'] ?? "Unknown Farm";
    final deviceId = widget.farm['deviceId'] ?? "N/A";
    final phone = widget.farm['phone'] ?? "";
    final status = widget.farm['status'] == 'Green' ? "Active" : "Inactive";
    final isActive = status == "Active";

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Farm Details",
            style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        foregroundColor: AppColors.getTextPrimary(Theme.of(context).brightness),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Profile Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 15,
                      offset: const Offset(0, 5))
                ],
                border: Border.all(color: Colors.grey.withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.landscape_rounded,
                        size: 40, color: AppColors.primary),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    name,
                    style: GoogleFonts.outfit(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.getTextPrimary(
                            Theme.of(context).brightness)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Device: $deviceId",
                    style: GoogleFonts.inter(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isActive
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "Status: $status",
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          color: isActive ? Colors.green : Colors.red),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Contact Actions — Message + Map only (no Call)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _actionButton(Icons.message_rounded, "Message",
                          Colors.teal, () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OfficerChatDetailScreen(
                              deviceId: deviceId,
                              farmerName: name,
                              farmerPhone: phone,
                            ),
                          ),
                        );
                      }),
                      const SizedBox(width: 24),
                      _actionButton(Icons.map_rounded, "Map", Colors.indigo,
                          () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    OfficerMapScreen(deviceId: deviceId)));
                      }),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn().slideY(begin: 0.1),


            // Farm Info Card
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Farm Information",
                      style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.getTextPrimary(
                              Theme.of(context).brightness))),
                  const SizedBox(height: 16),
                  _infoRow(Icons.devices_rounded, "Device ID", deviceId),
                  const SizedBox(height: 12),
                  _infoRow(Icons.person_rounded, "Farmer", name),
                  const SizedBox(height: 12),
                  _infoRow(
                      Icons.circle,
                      "Status",
                      status,
                      color: isActive ? Colors.green : Colors.red),
                ],
              ),
            ).animate().fadeIn(delay: const Duration(milliseconds: 150)).slideY(begin: 0.1),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value,
      {Color? color}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade500),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: GoogleFonts.inter(fontSize: 11, color: Colors.grey)),
            Text(value,
                style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color ??
                        AppColors.getTextPrimary(
                            Theme.of(context).brightness))),
          ],
        ),
      ],
    );
  }

  Widget _actionButton(
      IconData icon, String label, Color color, VoidCallback onTap) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
        ),
        const SizedBox(height: 8),
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700)),
      ],
    );
  }
}
