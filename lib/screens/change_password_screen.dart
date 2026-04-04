import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../app_theme.dart';
import '../services/auth_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  final String deviceId;

  const ChangePasswordScreen({super.key, required this.deviceId});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isLoading = false;
  bool showOld = false;
  bool showNew = false;
  bool showConfirm = false;

  Future<void> changePassword() async {
    if (oldPasswordController.text.isEmpty ||
        newPasswordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("All fields are required", style: GoogleFonts.inter()),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    if (newPasswordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Passwords do not match", style: GoogleFonts.inter()),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    bool success = await AuthService.changePassword(
      id: widget.deviceId,
      oldPassword: oldPasswordController.text.trim(),
      newPassword: newPasswordController.text.trim(),
    );

    if (!mounted) return;

    setState(() => isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Password changed successfully", style: GoogleFonts.inter()),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Incorrect old password", style: GoogleFonts.inter()),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          // ── Header ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            decoration: const BoxDecoration(
              gradient: AppColors.heroGradient,
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(32),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    "Change Password",
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Form ──
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.getCard(Theme.of(context).brightness),
                  borderRadius: BorderRadius.circular(24),
                  border: Theme.of(context).brightness == Brightness.dark
                      ? null
                      : Border.all(color: const Color(0xFFD6EDDE)),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.black.withOpacity(0.3)
                          : const Color(0xFF1E7A48).withOpacity(0.05),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Lock icon header
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.lock_reset_rounded,
                        color: AppColors.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Update your password",
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.getTextPrimary(Theme.of(context).brightness),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Enter your current password and choose a new one.",
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.getTextSecondary(Theme.of(context).brightness),
                      ),
                    ),
                    const SizedBox(height: 28),

                    _buildPasswordField(
                      label: "Current Password",
                      controller: oldPasswordController,
                      obscure: !showOld,
                      onToggle: () => setState(() => showOld = !showOld),
                    ),
                    const SizedBox(height: 16),
                    _buildPasswordField(
                      label: "New Password",
                      controller: newPasswordController,
                      obscure: !showNew,
                      onToggle: () => setState(() => showNew = !showNew),
                    ),
                    const SizedBox(height: 16),
                    _buildPasswordField(
                      label: "Confirm New Password",
                      controller: confirmPasswordController,
                      obscure: !showConfirm,
                      onToggle: () => setState(() => showConfirm = !showConfirm),
                    ),

                    const SizedBox(height: 32),

                    GradientButton(
                      text: "Update Password",
                      isLoading: isLoading,
                      onPressed: isLoading ? null : changePassword,
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 400.ms)
                  .slideY(begin: 0.08, end: 0, delay: 200.ms, duration: 400.ms),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.getTextSecondary(Theme.of(context).brightness),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark ? AppColors.surfaceVariant : const Color(0xFFE8F4EC),
            borderRadius: BorderRadius.circular(16),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscure,
            style: GoogleFonts.inter(
              fontSize: 15,
              color: AppColors.getTextPrimary(Theme.of(context).brightness),
            ),
            decoration: InputDecoration(
              hintText: "Enter $label",
              prefixIcon: Container(
                margin: const EdgeInsets.only(left: 4),
                child: const Icon(Icons.lock_outline_rounded, size: 20),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  obscure ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                  size: 20,
                ),
                onPressed: onToggle,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
