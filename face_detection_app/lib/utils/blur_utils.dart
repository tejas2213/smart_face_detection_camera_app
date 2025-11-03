import 'package:image/image.dart' as img;

bool isImageBlurry(img.Image image, double threshold) {
  final kernel = [
    [0, 1, 0],
    [1, -4, 1],
    [0, 1, 0],
  ];

  final width = image.width; 
  final height = image.height;
  List<double> values = [];

  for (int y = 1; y < height - 1; y++) {
    for (int x = 1; x < width - 1; x++) {
      double value = 0.0;
      for (int ky = -1; ky <= 1; ky++) {
        for (int kx = -1; kx <= 1; kx++) {
          final pixel = image.getPixel(x + kx, y + ky); 
          final gray = pixel.luminance; 
          
          value += kernel[ky + 1][kx + 1] * gray;
        }
      }
      values.add(value * value);
    }
  }

  double mean = values.reduce((a, b) => a + b) / values.length;
  return mean < threshold; 
}
