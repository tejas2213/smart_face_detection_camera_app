import 'dart:io';
import 'dart:async';
import 'package:face_detection_app/model/analysis_result.dart';
import 'package:face_detection_app/utils/blur_utils.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:image/image.dart' as img;

class ImageAnalysisController {
  Future<AnalysisResult> analyze(String path) async {
    final input = InputImage.fromFilePath(path);

    final futures = {
      'face': _detectFaces(input),
      'labels': _detectLabels(input),
      'blur': _detectBlur(path),
    };

    final results = await Future.wait(futures.values);
    final faces = results[0] as List<Face>;
    final labels = results[1] as List<ImageLabel>;
    final blurDetected = results[2] as bool;

    return AnalysisResult(
      hasFace: faces.isNotEmpty,
      eyesOpen: faces.isNotEmpty &&
          (faces.first.leftEyeOpenProbability ?? 0) > 0.5 &&
          (faces.first.rightEyeOpenProbability ?? 0) > 0.5,
      backgroundLabels: labels.map((e) => e.label).toList(),
      blurDetected: blurDetected,
    );
  }

  Future<List<Face>> _detectFaces(InputImage input) async {
    final faceDetector = FaceDetector(options: FaceDetectorOptions(
      enableClassification: true,
      enableLandmarks: true,
      performanceMode: FaceDetectorMode.fast,
    ));
    try {
      return await faceDetector.processImage(input);
    } finally {
      await faceDetector.close();
    }
  }

  Future<List<ImageLabel>> _detectLabels(InputImage input) async {
    final labeler = ImageLabeler(options: ImageLabelerOptions(
      confidenceThreshold: 0.7, 
    ));
    try {
      return await labeler.processImage(input);
    } finally {
      await labeler.close();
    }
  }

  Future<bool> _detectBlur(String path) async {
    final bytes = await File(path).readAsBytes();
    final decodedImage = img.decodeImage(bytes);
    if (decodedImage == null) return false;
    
    final smallImage = img.copyResize(decodedImage, width: 500);
    return isImageBlurry(smallImage, 1000.0);
  }
}