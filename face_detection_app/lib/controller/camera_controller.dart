import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class CameraViewController {
  CameraController? _cameraController;
  bool _isTorchOn = false;
  bool _isFrontCamera = false;
  bool _isCapturing = false;
  int _blinkCount = 0;
  late FaceDetector _faceDetector;
  //final bool _isFaceInsideFrame = false;

  CameraController? get cameraController => _cameraController;
  bool get isTorchOn => _isTorchOn;
  bool get isFrontCamera => _isFrontCamera;
  bool get isCapturing => _isCapturing;
  int get blinkCount => _blinkCount;
  //bool get isFaceInsideFrame => _isFaceInsideFrame;

  VoidCallback? onStateChanged;
  Function(String imagePath)? onImageCaptured;

  CameraViewController({
    this.onStateChanged,
    this.onImageCaptured,
  }) {
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableClassification: true, 
        enableLandmarks: true,
        performanceMode: FaceDetectorMode.fast
      ),
    );
  }

  Future<void> initializeCamera() async {
    final cameras = await availableCameras();
    final selectedCamera = _isFrontCamera 
        ? cameras.firstWhere((c) => c.lensDirection == CameraLensDirection.front)
        : cameras.firstWhere((c) => c.lensDirection == CameraLensDirection.back);

    _cameraController = CameraController(selectedCamera, ResolutionPreset.max);
    await _cameraController!.initialize();
    _cameraController!.startImageStream(_processImage);

    onStateChanged?.call();
  }

  Future<void> _processImage(CameraImage image) async {
    if (_isCapturing) return;

    final WriteBuffer allBytes = WriteBuffer();
    for (final plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final camera = _cameraController!.description;
    final rotation = _rotationIntToImageRotation(camera.sensorOrientation);

    final inputImage = InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: InputImageFormat.nv21,
        bytesPerRow: image.planes[0].bytesPerRow,
      ),
    );

    final faces = await _faceDetector.processImage(inputImage);

    if (faces.isNotEmpty) {
      final face = faces.first;
      final leftEye = face.leftEyeOpenProbability ?? 0;
      final rightEye = face.rightEyeOpenProbability ?? 0;

      if (leftEye < 0.4 && rightEye < 0.4) {
        _blinkCount++;
        if (_blinkCount >= 2) {
          await _capture();
        }
      }
    }
  }

  InputImageRotation _rotationIntToImageRotation(int rotation) {
    switch (rotation) {
      case 90:
        return InputImageRotation.rotation90deg;
      case 180:
        return InputImageRotation.rotation180deg;
      case 270:
        return InputImageRotation.rotation270deg;
      case 0:
      default:
        return InputImageRotation.rotation0deg;
    }
  }

  Future<void> _capture() async {
    _isCapturing = true;
    await _cameraController!.stopImageStream();
    final file = await _cameraController!.takePicture();
    onImageCaptured?.call(file.path);
  }

  Future<void> toggleTorch() async {
    _isTorchOn = !_isTorchOn;
    await _cameraController!.setFlashMode(_isTorchOn ? FlashMode.torch : FlashMode.off);
    onStateChanged?.call();
  }
  
  Future<void> switchCamera() async {
    _isFrontCamera = !_isFrontCamera;
    await _cameraController!.dispose();
    await initializeCamera();
  }

  void dispose() {
    _cameraController?.dispose();
    _faceDetector.close();
  }
}

