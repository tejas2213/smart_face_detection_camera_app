import 'dart:io';
import 'package:face_detection_app/controller/image_analysis_controller.dart';
import 'package:face_detection_app/model/analysis_result.dart';
import 'package:face_detection_app/router_constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PhotoAnalysisView extends StatefulWidget {
  final String imagePath;
  const PhotoAnalysisView({super.key, required this.imagePath});

  @override
  State<PhotoAnalysisView> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<PhotoAnalysisView> {
  AnalysisResult? result;
  final analyzer = ImageAnalysisController();

  @override
  void initState() {
    super.initState();
    analyzer.analyze(widget.imagePath).then((res) {
      setState(() => result = res);
    });
  }

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Photo Analysis'),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Image Preview
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withOpacity(0.3),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: Image.file(
                    File(widget.imagePath),
                    height: 400,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              if (result == null)
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Analyzing photo...',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              else ...[
                // Analysis Results Cards
                _buildResultCard(
                  icon: Icons.face,
                  iconColor: const Color(0xFF6366F1),
                  title: 'Face Detection',
                  value: result!.hasFace ? 'Detected ✓' : 'Not Detected',
                  isPositive: result!.hasFace,
                ),
                const SizedBox(height: 12),
                _buildResultCard(
                  icon: Icons.remove_red_eye,
                  iconColor: const Color(0xFF8B5CF6),
                  title: 'Eyes Status',
                  value: result!.eyesOpen ? 'Open ✓' : 'Closed',
                  isPositive: result!.eyesOpen,
                ),
                const SizedBox(height: 12),
                if (result!.backgroundLabels.isNotEmpty)
                  _buildResultCard(
                    icon: Icons.image,
                    iconColor: const Color(0xFFFF6B6B),
                    title: 'Background',
                    value: result!.backgroundLabels.join(', '),
                    isPositive: false,
                  ),
                const SizedBox(height: 12),
                _buildResultCard(
                  icon: Icons.blur_on,
                  iconColor: const Color(0xFFFFD93D),
                  title: 'Image Quality',
                  value: result!.blurDetected ? 'Blurry' : 'Clear ✓',
                  isPositive: !result!.blurDetected,
                ),
                const SizedBox(height: 32),
                
                // Action Button
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: (result!.blurDetected || result!.backgroundLabels.isNotEmpty)
                        ? const LinearGradient(
                            colors: [Color(0xFFFF6B6B), Color(0xFFFF8787)],
                          )
                        : const LinearGradient(
                            colors: [Color(0xFF10B981), Color(0xFF34D399)],
                          ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: (result!.blurDetected || result!.backgroundLabels.isNotEmpty)
                            ? const Color(0xFFFF6B6B).withOpacity(0.4)
                            : const Color(0xFF10B981).withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: result!.blurDetected || result!.backgroundLabels.isNotEmpty
                          ? () => context.pushNamed(Routes.CAMERA_VIEW)
                          : null,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              result!.blurDetected || result!.backgroundLabels.isNotEmpty
                                  ? Icons.camera_alt
                                  : Icons.check_circle_outline,
                              color: Colors.white,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              result!.blurDetected || result!.backgroundLabels.isNotEmpty
                                  ? 'Retake Photo'
                                  : 'Perfect!',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required bool isPositive,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPositive 
              ? const Color(0xFF10B981).withOpacity(0.3)
              : const Color(0xFF64748B).withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: isPositive 
                        ? const Color(0xFF10B981)
                        : const Color(0xFF1E293B),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
