class AnalysisResult {
  final bool hasFace;
  final bool eyesOpen;
  final bool blurDetected;
  final List<String> backgroundLabels;

  AnalysisResult({
    required this.hasFace,
    required this.eyesOpen,
    required this.blurDetected,
    required this.backgroundLabels,
  });
}
