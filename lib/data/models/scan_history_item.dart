import 'fruit_quality.dart';
import 'prediction_result.dart';

class ScanHistoryItem {
  final int? id;
  final String imagePath;
  final String fruitName;
  final FruitQuality quality;
  final double confidence;
  final double probGood;
  final double probFair;
  final double probBad;
  final int inferenceMs;
  final String source;
  final DateTime createdAt;

  const ScanHistoryItem({
    this.id,
    required this.imagePath,
    required this.fruitName,
    required this.quality,
    required this.confidence,
    required this.probGood,
    required this.probFair,
    required this.probBad,
    required this.inferenceMs,
    required this.source,
    required this.createdAt,
  });

  factory ScanHistoryItem.fromPrediction({
    required PredictionResult prediction,
    required String imagePath,
    String source = 'mock',
  }) {
    return ScanHistoryItem(
      imagePath: imagePath,
      fruitName: prediction.fruit,
      quality: prediction.quality,
      confidence: prediction.confidence,
      probGood: prediction.probabilities['bagus'] ?? (prediction.quality == FruitQuality.bagus ? prediction.confidence : 0.0),
      probFair: prediction.probabilities['cukup'] ?? (prediction.quality == FruitQuality.cukup ? prediction.confidence : 0.0),
      probBad: prediction.probabilities['busuk'] ?? (prediction.quality == FruitQuality.busuk ? prediction.confidence : 0.0),
      inferenceMs: prediction.inferenceTimeMs,
      source: source,
      createdAt: DateTime.now(),
    );
  }

  factory ScanHistoryItem.fromMap(Map<String, dynamic> map) {
    return ScanHistoryItem(
      id: map['id'] as int?,
      imagePath: map['image_path'] as String? ?? '',
      fruitName: map['fruit_name'] as String? ?? 'buah',
      quality: FruitQuality.fromString(map['quality'] as String? ?? 'cukup'),
      confidence: (map['confidence'] as num?)?.toDouble() ?? 0.0,
      probGood: (map['prob_good'] as num?)?.toDouble() ?? 0.0,
      probFair: (map['prob_fair'] as num?)?.toDouble() ?? 0.0,
      probBad: (map['prob_bad'] as num?)?.toDouble() ?? 0.0,
      inferenceMs: (map['inference_ms'] as num?)?.toInt() ?? 0,
      source: map['source'] as String? ?? 'mock',
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'image_path': imagePath,
      'fruit_name': fruitName,
      'quality': quality.name,
      'confidence': confidence,
      'prob_good': probGood,
      'prob_fair': probFair,
      'prob_bad': probBad,
      'inference_ms': inferenceMs,
      'source': source,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
