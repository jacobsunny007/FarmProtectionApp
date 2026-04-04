import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../app_theme.dart';
import '../services/auth_service.dart';
import 'farmer_dashboard.dart';
import 'officer_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController idController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String selectedRole = "farmer";
  bool showPassword = false;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.splashGradient,
        ),
        child: Stack(
          children: [
            // ── Decorative circles ──
            Positioned(
              top: -60,
              right: -40,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),
            Positioned(
              bottom: -80,
              left: -60,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.04),
                ),
              ),
            ),

            // ── Main content ──
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      // ── Logo & Branding ──
                      ClipOval(
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const Icon(
                                Icons.shield_rounded,
                                size: 72,
                                color: AppColors.primary,
                              ),
                              const Positioned(
                                bottom: 12,
                                child: Icon(
                                  Icons.eco_rounded,
                                  size: 42,
                                  color: AppColors.accent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      Text(
                        "EcoWatch",
                        style: GoogleFonts.poppins(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        "Farm Monitoring System",
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.8),
                          letterSpacing: 0.5,
                        ),
                      ),

                      const SizedBox(height: 40),

                      // ── Glass Login Card ──
                      GlassCard(
                        padding: const EdgeInsets.all(28),
                        opacity: 0.12,
                        child: Column(
                          children: [
                            // ── Role Selector ──
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _roleTab(
                                      icon: Icons.agriculture_rounded,
                                      text: "Farmer",
                                      isSelected: selectedRole == "farmer",
                                      color: AppColors.accent,
                                      onTap: () => setState(
                                          () => selectedRole = "farmer"),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: _roleTab(
                                      icon: Icons.shield_rounded,
                                      text: "Officer",
                                      isSelected: selectedRole == "officer",
                                      color: AppColors.amber,
                                      onTap: () => setState(
                                          () => selectedRole = "officer"),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 28),

                            // ── ID Field ──
                            StyledInputField(
                              icon: Icons.badge_rounded,
                              hint: selectedRole == "farmer"
                                  ? "Device ID"
                                  : "Officer ID",
                              controller: idController,
                            ),

                            const SizedBox(height: 16),

                            // ── Password Field ──
                            StyledInputField(
                              icon: Icons.lock_rounded,
                              hint: "Password",
                              controller: passwordController,
                              isPassword: true,
                              showPassword: showPassword,
                              onTogglePassword: () {
                                setState(
                                    () => showPassword = !showPassword);
                              },
                            ),

                            const SizedBox(height: 32),

                            // ── Login Button ──
                            GradientButton(
                              text: "Sign In",
                              isLoading: isLoading,
                              onPressed: isLoading ? null : handleLogin,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Role Tab Widget ──
  Widget _roleTab({
    required IconData icon,
    required String text,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.6),
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color:
                    isSelected ? Colors.white : Colors.white.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Login Handler ──
  Future<void> handleLogin() async {
    if (idController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Please enter your ID and password",
            style: GoogleFonts.inter(),
          ),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    final result = await AuthService.login(
      id: idController.text.trim(),
      password: passwordController.text.trim(),
      role: selectedRole,
    );

    setState(() => isLoading = false);

    if (result != null) {
      if (selectedRole == "farmer") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                FarmerDashboard(deviceId: result["deviceId"]),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                OfficerDashboard(officerId: result["officerId"]),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Invalid credentials. Please try again.",
            style: GoogleFonts.inter(),
          ),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }
}
