import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import '../app_theme.dart';
import '../services/officer_service.dart';
import '../services/analytics_service.dart';

class OfficerInsightsScreen extends StatefulWidget {
  const OfficerInsightsScreen({super.key});

  @override
  State<OfficerInsightsScreen> createState() => _OfficerInsightsScreenState();
}

class _OfficerInsightsScreenState extends State<OfficerInsightsScreen> {
  bool isLoading = true;
  Map<String, dynamic>? officerInsights;
  List<ChartDataPoint> historyData = [];
  List<ChartDataPoint> animalsData = [];
  List<ChartDataPoint> risksData = [];

  @override
  void initState() {
    super.initState();
    _fetchAllData();
  }

  Future<void> _fetchAllData() async {
    try {
      final results = await Future.wait([
        OfficerService.getInsights(),
        AnalyticsService.getGlobalHistory(),
        AnalyticsService.getGlobalAnimals(),
        AnalyticsService.getGlobalRisks(),
      ]);

      if (mounted) {
        setState(() {
          officerInsights = results[0] as Map<String, dynamic>?;
          historyData = results[1] as List<ChartDataPoint>;
          animalsData = results[2] as List<ChartDataPoint>;
          risksData = results[3] as List<ChartDataPoint>;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading insights: $e");
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    return RefreshIndicator(
      onRefresh: _fetchAllData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Global Farm Analytics",
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.getTextPrimary(Theme.of(context).brightness),
              ),
            ).animate().fadeIn().slideY(begin: 0.1),
            const SizedBox(height: 20),

            // Smart Cards
            Row(
              children: [
                Expanded(
                  child: _insightCard(
                    title: "Frequent Animal",
                    value: officerInsights?['frequentAnimal']?.toString().toUpperCase() ?? "--",
                    icon: Icons.pets_rounded,
                    iconColor: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _insightCard(
                    title: "Peak Time",
                    value: officerInsights?['peakTimeRange'] ?? "--",
                    icon: Icons.access_time_filled_rounded,
                    iconColor: Colors.indigo,
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 100.ms).slideX(begin: 0.1),

            const SizedBox(height: 24),
            
            // Recommendation Alert
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.amber.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.tips_and_updates_rounded, color: Colors.amber, size: 28),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("AI Recommendation", style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.amber.shade800)),
                        const SizedBox(height: 4),
                        Text(
                          officerInsights?['aiRecommendation'] ?? 
                          "Increased activity detected between ${officerInsights?['peakTimeRange'] ?? '18:00 - 22:00'}. Dispatch additional units during these hours.",
                          style: GoogleFonts.inter(fontSize: 12, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 150.ms),

            const SizedBox(height: 32),

            // History Line Chart
            _chartContainer(
              title: "7-Day Detection Trend",
              child: _buildHistoryChart(),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),

            const SizedBox(height: 24),

            // Risk Pie Chart
            _chartContainer(
              title: "Risk Distribution",
              child: _buildRiskPieChart(),
              height: 250,
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),

            const SizedBox(height: 24),

            // Animal Bar Chart
            _chartContainer(
              title: "Top Detected Species",
              child: _buildAnimalBarChart(),
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),

            const SizedBox(height: 32),
            Text(
              "⚠ High-Risk Farms",
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.getTextPrimary(Theme.of(context).brightness),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Sorted by highest alert count",
              style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ...(officerInsights?['highRiskZones'] as List? ?? []).map((zone) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.red.withOpacity(0.15)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4)),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.landscape_rounded,
                          color: Colors.red, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            zone['name'] ?? zone['deviceId'] ?? 'Unknown Farm',
                            style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: AppColors.getTextPrimary(
                                    Theme.of(context).brightness)),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Device: ${zone['deviceId'] ?? 'N/A'}",
                            style: GoogleFonts.inter(
                                fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12)),
                      child: Text(
                        "${zone['alertCount'] ?? zone['highRiskCount'] ?? 0} alerts",
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            color: Colors.red,
                            fontSize: 13),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _insightCard({required String title, required String value, required IconData icon, required Color iconColor}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: iconColor.withOpacity(0.15), shape: BoxShape.circle),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(title, style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade600), maxLines: 1),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.getTextPrimary(Theme.of(context).brightness)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _chartContainer({required String title, required Widget child, double height = 300}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          SizedBox(
            height: height,
            child: child,
          ),
        ],
      ),
    );
  }

  // --- Charts ---

  Widget _buildHistoryChart() {
    if (historyData.isEmpty) return const Center(child: Text("No data"));
    
    List<FlSpot> spots = [];
    for (int i = 0; i < historyData.length; i++) {
      spots.add(FlSpot(i.toDouble(), historyData[i].count.toDouble()));
    }

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < 0 || value.toInt() >= historyData.length) return const SizedBox();
                final dateParts = historyData[value.toInt()].label.split('-');
                final label = dateParts.length >= 3 ? "${dateParts[1]}/${dateParts[2]}" : historyData[value.toInt()].label;
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(label, style: GoogleFonts.inter(fontSize: 10, color: Colors.grey)),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.primary,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.primary.withOpacity(0.15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskPieChart() {
    if (risksData.isEmpty) return const Center(child: Text("No data"));

    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections: risksData.map((data) {
          final level = data.label.toLowerCase();
          Color color = Colors.grey;
          if (level == 'high') color = Colors.red;
          if (level == 'medium') color = Colors.orange;
          if (level == 'low') color = Colors.green;

          return PieChartSectionData(
            color: color,
            value: data.count.toDouble(),
            title: "${data.label}\n(${data.count})",
            radius: 50,
            titleStyle: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAnimalBarChart() {
    if (animalsData.isEmpty) return const Center(child: Text("No data"));

    return BarChart(
      BarChartData(
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < 0 || value.toInt() >= animalsData.length) return const SizedBox();
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(animalsData[value.toInt()].label, style: GoogleFonts.inter(fontSize: 10, color: Colors.grey)),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(animalsData.length, (index) {
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: animalsData[index].count.toDouble(),
                color: Colors.blueAccent,
                width: 20,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }),
      ),
    );
  }

  // Hourly heatmap chart removed (was getGlobalAlertsByTime)
}
