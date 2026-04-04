import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:audioplayers/audioplayers.dart';
import '../app_theme.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool enableSound = true;
  String selectedSound = "default";
  final AudioPlayer _audioPlayer = AudioPlayer();

  final List<Map<String, String>> sounds = [
    {"id": "default", "name": "Default Alert"},
    {"id": "siren", "name": "Siren Alert"},
    {"id": "bell", "name": "Bell Alert"},
    {"id": "silent", "name": "Silent"},
  ];

  void _playSound(String soundId) {
    if (!enableSound || soundId == "silent") return;
    
    // In a fully built app, this would trigger the actual asset playback:
    // _audioPlayer.play(AssetSource('sounds/$soundId.mp3'));
    
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Testing $soundId tone...", style: GoogleFonts.inter()),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Notification Sound"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Enable Sound Toggle ──
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.getCard(Theme.of(context).brightness),
                borderRadius: BorderRadius.circular(16),
                border: Theme.of(context).brightness == Brightness.dark
                    ? null
                    : Border.all(color: const Color(0xFFD6EDDE)),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.black.withOpacity(0.3)
                        : const Color(0xFF1E7A48).withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Enable Alert Sound",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.getTextPrimary(Theme.of(context).brightness),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Play an audible notification when the system detects wildlife",
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppColors.getTextSecondary(Theme.of(context).brightness),
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Switch.adaptive(
                    value: enableSound,
                    activeColor: AppColors.primary,
                    onChanged: (val) {
                      setState(() {
                        enableSound = val;
                      });
                    },
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0),

            const SizedBox(height: 32),

            Text(
              "Select Alert Tone",
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.getTextSecondary(Theme.of(context).brightness),
              ),
            ).animate().fadeIn(delay: 100.ms),
            
            const SizedBox(height: 16),

            // ── Sound Selection List ──
            Container(
              decoration: BoxDecoration(
                color: AppColors.getCard(Theme.of(context).brightness),
                borderRadius: BorderRadius.circular(16),
                border: Theme.of(context).brightness == Brightness.dark
                    ? null
                    : Border.all(color: const Color(0xFFD6EDDE)),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.black.withOpacity(0.3)
                        : const Color(0xFF1E7A48).withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: sounds.asMap().entries.map((entry) {
                  final index = entry.key;
                  final sound = entry.value;
                  final isLast = index == sounds.length - 1;
                  
                  return Column(
                    children: [
                      _soundOption(sound["id"]!, sound["name"]!),
                      if (!isLast) const Divider(height: 1, indent: 20, endIndent: 20),
                    ],
                  );
                }).toList(),
              ),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.05, end: 0),
          ],
        ),
      ),
    );
  }

  Widget _soundOption(String id, String name) {
    final isSelected = selectedSound == id;
    final isDisabled = !enableSound && id != "silent";

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      enabled: !isDisabled,
      leading: Icon(
        id == "silent" ? Icons.volume_off_rounded : Icons.music_note_rounded,
        color: isDisabled
            ? AppColors.getTextTertiary(Theme.of(context).brightness)
            : (isSelected ? AppColors.primary : AppColors.getTextSecondary(Theme.of(context).brightness)),
      ),
      title: Text(
        name,
        style: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          color: isDisabled
              ? AppColors.getTextTertiary(Theme.of(context).brightness)
              : AppColors.getTextPrimary(Theme.of(context).brightness),
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
          : null,
      onTap: () {
        if (isDisabled) return;
        setState(() {
          selectedSound = id;
        });
        _playSound(id);
      },
    );
  }
}
