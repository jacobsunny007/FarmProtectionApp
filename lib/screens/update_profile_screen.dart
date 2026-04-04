import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../app_theme.dart';
import '../services/auth_service.dart';

class UpdateProfileScreen extends StatefulWidget {
  final String deviceId;

  const UpdateProfileScreen({super.key, required this.deviceId});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final locationController = TextEditingController();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    detectLocation();
  }

  Future<void> detectLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);

    Placemark place = placemarks.first;

    setState(() {
      locationController.text =
          "${place.locality}, ${place.administrativeArea}";
    });
  }

  Future<void> updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    bool success = await AuthService.updateProfile(
      id: widget.deviceId,
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      phone: phoneController.text.trim(),
      location: locationController.text.trim(),
    );

    if (!mounted) return;

    setState(() => isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Profile updated successfully", style: GoogleFonts.inter()),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Update failed", style: GoogleFonts.inter()),
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
                    "Update Profile",
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile icon header
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          color: AppColors.primary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Your Information",
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.getTextPrimary(Theme.of(context).brightness),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Update your personal details below.",
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.getTextSecondary(Theme.of(context).brightness),
                        ),
                      ),
                      const SizedBox(height: 28),

                      _buildField(
                        label: "Full Name",
                        icon: Icons.person_outline_rounded,
                        controller: nameController,
                        hint: "Enter your name",
                        required: true,
                      ),
                      const SizedBox(height: 16),
                      _buildField(
                        label: "Email Address",
                        icon: Icons.email_outlined,
                        controller: emailController,
                        hint: "Enter your email",
                        required: true,
                      ),
                      const SizedBox(height: 16),
                      _buildField(
                        label: "Phone Number",
                        icon: Icons.phone_outlined,
                        controller: phoneController,
                        hint: "Enter your phone number",
                        required: true,
                      ),
                      const SizedBox(height: 16),
                      _buildField(
                        label: "Location",
                        icon: Icons.location_on_outlined,
                        controller: locationController,
                        hint: "Detecting location...",
                        readOnly: true,
                        required: false,
                      ),

                      const SizedBox(height: 32),

                      GradientButton(
                        text: "Save Changes",
                        isLoading: isLoading,
                        onPressed: isLoading ? null : updateProfile,
                      ),
                    ],
                  ),
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

  Widget _buildField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required String hint,
    bool readOnly = false,
    bool required = true,
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
            color: readOnly
                ? (Theme.of(context).brightness == Brightness.dark ? AppColors.surfaceVariant.withOpacity(0.7) : const Color(0xFFE8F4EC).withOpacity(0.7))
                : (Theme.of(context).brightness == Brightness.dark ? AppColors.surfaceVariant : const Color(0xFFE8F4EC)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: TextFormField(
            controller: controller,
            readOnly: readOnly,
            style: GoogleFonts.inter(
              fontSize: 15,
              color: readOnly ? AppColors.getTextSecondary(Theme.of(context).brightness) : AppColors.getTextPrimary(Theme.of(context).brightness),
            ),
            validator: required
                ? (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "$label is required";
                    }
                    return null;
                  }
                : null,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Container(
                margin: const EdgeInsets.only(left: 4),
                child: Icon(icon, size: 20),
              ),
              suffixIcon: readOnly
                  ? Icon(
                      Icons.my_location_rounded,
                      size: 20,
                      color: AppColors.primary.withOpacity(0.6),
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}
