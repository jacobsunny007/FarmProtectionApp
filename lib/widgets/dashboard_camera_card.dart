import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';
import '../models/camera_model.dart';
import '../services/camera_service.dart';
import '../screens/camera_details_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DashboardCameraCard extends StatefulWidget {
  final CameraDevice camera;
  final String deviceId;
  final int index;

  const DashboardCameraCard({
    Key? key,
    required this.camera,
    required this.deviceId,
    required this.index,
  }) : super(key: key);

  @override
  State<DashboardCameraCard> createState() => _DashboardCameraCardState();
}

class _DashboardCameraCardState extends State<DashboardCameraCard> {
  RTCPeerConnection? _pc;
  final RTCVideoRenderer _renderer = RTCVideoRenderer();
  bool _isInitializing = false;
  bool _hasVideo = false;

  @override
  void initState() {
    super.initState();
    if (widget.camera.isConnected) {
      _initStream();
    }
  }

  Future<void> _initStream() async {
    setState(() {
      _isInitializing = true;
    });
    
    await _renderer.initialize();

    _pc = await createPeerConnection({
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
        {
          'urls': 'turn:openrelay.metered.ca:80',
          'username': 'openrelayproject',
          'credential': 'openrelayproject'
        },
        {
          'urls': 'turn:openrelay.metered.ca:443',
          'username': 'openrelayproject',
          'credential': 'openrelayproject'
        }
      ]
    });

    _pc!.onTrack = (event) {
      if (event.streams.isNotEmpty) {
        _renderer.srcObject = event.streams[0];
        _hasVideo = true;
      } else {
        if (_renderer.srcObject == null) {
          createLocalMediaStream('remote_stream').then((stream) {
            stream.addTrack(event.track);
            _renderer.srcObject = stream;
            _hasVideo = true;
            if (mounted) setState(() {});
          });
        } else {
          _renderer.srcObject!.addTrack(event.track);
          _hasVideo = true;
        }
      }
      if (mounted) setState(() {});
    };

    try {
      final streamUrl = CameraService.getStreamUrl(widget.deviceId);

      await _pc!.addTransceiver(
        kind: RTCRtpMediaType.RTCRtpMediaTypeVideo,
        init: RTCRtpTransceiverInit(direction: TransceiverDirection.RecvOnly),
      );

      var offer = await _pc!.createOffer();
      await _pc!.setLocalDescription(offer);

      final res = await http.post(
        Uri.parse(streamUrl),
        headers: {
          "Content-Type": "application/sdp",
          "Accept": "application/sdp",
        },
        body: offer.sdp,
      );

      if (res.statusCode >= 200 && res.statusCode < 300) {
        String sdp = res.body;
        await _pc!.setRemoteDescription(
          RTCSessionDescription(sdp, "answer"),
        );
      }
    } catch (e) {
      debugPrint("Camera card WebRTC error: \$e");
    } finally {
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _renderer.dispose();
    _pc?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isOffline = !widget.camera.isConnected;
    Color statusColor = isOffline ? AppColors.textTertiary : AppColors.success;
    String statusText = isOffline ? "Camera Not Connected" : "Connected";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Container(
        height: 220,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppColors.cardDark,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Video or Placeholder
            if (isOffline)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.videocam_off_rounded,
                      size: 48,
                      color: Color(0xFF475569),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        "Camera Not Connected",
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else if (_hasVideo && _renderer.srcObject != null)
               SizedBox.expand(
                child: RTCVideoView(
                  _renderer,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                ),
              )
            else
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.videocam_rounded,
                      size: 48,
                      color: Color(0xFF475569),
                    ),
                    if (_isInitializing)
                      const Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: CircularProgressIndicator(color: Colors.white54),
                      ),
                  ],
                ),
              ),

            // Navigation Tap Area (covers the whole card EXCEPT the fullscreen button, but we'll just handle it generally, fullscreen button overlaps)
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                     Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CameraDetailsScreen(
                          camera: widget.camera,
                          deviceId: widget.deviceId,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Dark gradient overlay strictly for text readability
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xDD000000)],
                  stops: [0.4, 1.0],
                ),
              ),
            ),

            // LIVE badge
            if (!isOffline)
              Positioned(
                top: 16,
                left: 16,
                child: IgnorePointer(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.danger,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.danger.withOpacity(0.4),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "LIVE",
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // OFFLINE badge
            if (isOffline)
              Positioned(
                top: 16,
                left: 16,
                child: IgnorePointer(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.textTertiary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "OFFLINE",
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Status dot Indicator removed as requested

            // Bottom info
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IgnorePointer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.camera.name,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          widget.camera.location.isNotEmpty ? widget.camera.location : "Zone \${widget.index + 1}",
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          statusText,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isOffline)
                    GestureDetector(
                      onTap: () {
                        // Navigates to full details screen on expanding
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CameraDetailsScreen(
                              camera: widget.camera,
                              deviceId: widget.deviceId,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: const Icon(
                          Icons.fullscreen_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ).animate()
        .fadeIn(delay: (300 + widget.index * 150).ms, duration: 400.ms)
        .slideX(
          begin: 0.05,
          end: 0,
          delay: (300 + widget.index * 150).ms,
          duration: 400.ms,
        ),
    );
  }
}
