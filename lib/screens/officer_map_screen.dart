import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../app_theme.dart';

class OfficerMapScreen extends StatelessWidget {
  final String? deviceId;
  const OfficerMapScreen({super.key, this.deviceId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text("Live Map", style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          // Simulated Map Background
          Positioned.fill(
            child: Container(
              color: Colors.green.shade50, // base map color
              child: CustomPaint(
                painter: GridPainter(),
              ),
            ),
          ),
          
          // Simulated Map Elements
          Positioned(
            top: 150,
            left: 80,
            child: _mapPin(active: true, risk: 'high', label: "Farm 12A").animate(onPlay: (controller) => controller.repeat()).scaleXY(begin: 1.0, end: 1.2, duration: 800.ms).then().scaleXY(begin: 1.2, end: 1.0, duration: 800.ms),
          ),
          Positioned(
            bottom: 250,
            right: 100,
            child: _mapPin(active: false, label: "Farm 8B").animate().fadeIn(delay: 200.ms),
          ),
          Positioned(
            top: 300,
            right: 60,
            child: _mapPin(active: true, risk: 'low', label: "Farm 9C").animate().fadeIn(delay: 300.ms),
          ),

          // API Key Required Overlay
          Positioned.fill(
            child: Container(
              color: Colors.white.withOpacity(0.4),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: Colors.indigo.withOpacity(0.1), shape: BoxShape.circle),
                        child: const Icon(Icons.map_rounded, color: Colors.indigo, size: 40),
                      ),
                      const SizedBox(height: 16),
                      Text("Map Integration", style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(
                        "Live Google Maps or Mapbox integration requires native API keys to be configured in AndroidManifest.xml and AppDelegate.swift.",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(color: Colors.grey.shade600, fontSize: 13, height: 1.5),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("Go Back", style: TextStyle(color: Colors.white)),
                      )
                    ],
                  ),
                ).animate().scale(delay: 400.ms, curve: Curves.easeOutBack),
              ),
            ),
          ),
          
          // Floating Search UI overlay
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
              ),
              child: TextField(
                enabled: false,
                decoration: InputDecoration(
                  hintText: "Search for a farm...",
                  hintStyle: GoogleFonts.inter(color: Colors.grey),
                  border: InputBorder.none,
                  icon: const Icon(Icons.search, color: Colors.grey),
                ),
              ),
            ).animate().slideY(begin: -1.0, duration: 500.ms),
          ),
        ],
      ),
    );
  }

  Widget _mapPin({required bool active, String risk = 'low', required String label}) {
    Color pinColor = Colors.grey;
    if (active) {
      if (risk == 'high') pinColor = Colors.red;
      else if (risk == 'medium') pinColor = Colors.orange;
      else pinColor = Colors.green;
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
          ),
          child: Text(label, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 4),
        Icon(Icons.location_on, color: pinColor, size: 40),
      ],
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green.withOpacity(0.1)
      ..strokeWidth = 1.0;

    for (double i = 0; i < size.width; i += 40) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 40) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
