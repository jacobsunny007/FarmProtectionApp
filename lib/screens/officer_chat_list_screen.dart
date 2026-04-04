import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../app_theme.dart';
import '../services/officer_service.dart';
import 'officer_chat_detail_screen.dart';

class OfficerChatListScreen extends StatefulWidget {
  const OfficerChatListScreen({super.key});

  @override
  State<OfficerChatListScreen> createState() => _OfficerChatListScreenState();
}

class _OfficerChatListScreenState extends State<OfficerChatListScreen> {
  bool isLoading = true;
  List<dynamic> farms = [];

  @override
  void initState() {
    super.initState();
    _fetchFarms();
  }

  Future<void> _fetchFarms() async {
    setState(() => isLoading = true);
    final data = await OfficerService.getFarms();
    if (mounted) {
      setState(() {
        farms = data;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (farms.isEmpty) {
      return Center(
        child: Text(
          "No active farms to chat with.",
          style: GoogleFonts.inter(color: Colors.grey),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchFarms,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: farms.length,
        itemBuilder: (context, index) {
          final farm = farms[index];
          final deviceId = farm['deviceId'] ?? 'Unknown';
          final name = farm['name']?.isNotEmpty == true ? farm['name'] : 'Farmer - $deviceId';
          final phone = farm['phone'] ?? '';
          
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              leading: CircleAvatar(
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: const Icon(Icons.person, color: AppColors.primary),
              ),
              title: Text(
                name,
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: Text(
                "Farm ID: $deviceId",
                style: GoogleFonts.inter(color: Colors.grey, fontSize: 13),
              ),
              trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
              onTap: () {
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
              },
            ),
          ).animate().fadeIn(delay: Duration(milliseconds: 50 * index)).slideX(begin: 0.05);
        },
      ),
    );
  }
}
