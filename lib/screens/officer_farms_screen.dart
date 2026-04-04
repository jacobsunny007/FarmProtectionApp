import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../app_theme.dart';
import '../services/officer_service.dart';
import 'officer_farm_detail_screen.dart';

class OfficerFarmsScreen extends StatefulWidget {
  const OfficerFarmsScreen({super.key});

  @override
  State<OfficerFarmsScreen> createState() => _OfficerFarmsScreenState();
}

class _OfficerFarmsScreenState extends State<OfficerFarmsScreen> {
  bool isLoading = true;
  List<dynamic> farms = [];

  @override
  void initState() {
    super.initState();
    _fetchFarms();
  }

  Future<void> _fetchFarms() async {
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
          "No registered farms to display.",
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
          final isActive = farm['status'] == 'Green';
          
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OfficerFarmDetailScreen(farm: farm),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isActive ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isActive ? Colors.green : Colors.red).withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: isActive ? Colors.green.withOpacity(0.15) : Colors.red.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.landscape_rounded,
                          color: isActive ? Colors.green : Colors.red,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              farm['name'] ?? "Unknown Farm",
                              style: GoogleFonts.outfit(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.getTextPrimary(Theme.of(context).brightness),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Device: ${farm['deviceId']}",
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isActive ? Colors.green : Colors.red,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: (isActive ? Colors.green : Colors.red).withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ]
                        ),
                        child: Text(
                          isActive ? "Active Monitoring" : "Offline",
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(height: 1),
                  ),
                  Row(
                    children: [
                      Icon(Icons.history_rounded, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 8),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade600),
                            children: [
                              const TextSpan(text: "Last Alert: "),
                              TextSpan(
                                text: "${farm['lastAlertAnimal'].toString().toUpperCase()}",
                                style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppColors.getTextPrimary(Theme.of(context).brightness)),
                              ),
                              if (farm['lastAlertTime'] != null)
                                TextSpan(
                                  text: " on ${farm['lastAlertTime'].toString().substring(0, 10)}",
                                ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
                    ],
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(delay: Duration(milliseconds: 50 * index)).slideY(begin: 0.1);
        },
      ),
    );
  }
}
