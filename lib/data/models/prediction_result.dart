import 'fruit_quality.dart';

class PredictionResult {
  final bool success;
  final String fruit;
  final FruitQuality quality;
  final double confidence;
  final Map<String, double> probabilities;
  final int inferenceTimeMs;
  final String? imagePath;

  const PredictionResult({
    required this.success,
    required this.fruit,
    required this.quality,
    required this.confidence,
    required this.probabilities,
    required this.inferenceTimeMs,
    this.imagePath,
  });

  factory PredictionResult.fromJson(Map<String, dynamic> json, {String? imagePath}) {
    final rawProbabilities = json['probabilities'] as Map<String, dynamic>? ?? {};
    final parsedProbabilities = rawProbabilities.map(
      (key, value) => MapEntry(key, (value as num).toDouble()),
    );

    return PredictionResult(
      success: json['success'] as bool? ?? true,
      fruit: json['fruit'] as String? ?? 'buah',
      quality: FruitQuality.fromString(json['quality'] as String? ?? 'cukup'),
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      probabilities: parsedProbabilities,
      inferenceTimeMs: (json['inference_time_ms'] as num?)?.toInt() ?? 0,
      imagePath: imagePath,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'fruit': fruit,
      'quality': quality.name,
      'confidence': confidence,
      'probabilities': probabilities,
      'inference_time_ms': inferenceTimeMs,
      if (imagePath != null) 'image_path': imagePath,
    };
  }

  PredictionResult copyWith({String? imagePath}) {
    return PredictionResult(
      success: success,
      fruit: fruit,
      quality: quality,
      confidence: confidence,
      probabilities: probabilities,
      inferenceTimeMs: inferenceTimeMs,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}
