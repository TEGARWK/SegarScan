import 'package:flutter_test/flutter_test.dart';
import 'package:segarscan/data/models/fruit_quality.dart';
import 'package:segarscan/data/models/prediction_result.dart';

void main() {
  group('PredictionResult & FruitQuality Model Tests', () {
    test('PredictionResult parses JSON contract correctly', () {
      final json = {
        'success': true,
        'fruit': 'apel',
        'quality': 'bagus',
        'confidence': 0.93,
        'probabilities': {
          'bagus': 0.93,
          'cukup': 0.05,
          'busuk': 0.02,
        },
        'inference_time_ms': 142,
      };

      final result = PredictionResult.fromJson(json);

      expect(result.success, isTrue);
      expect(result.fruit, 'apel');
      expect(result.quality, FruitQuality.bagus);
      expect(result.confidence, 0.93);
      expect(result.probabilities['bagus'], 0.93);
      expect(result.probabilities['cukup'], 0.05);
      expect(result.probabilities['busuk'], 0.02);
      expect(result.inferenceTimeMs, 142);
    });

    test('FruitQuality handles different case strings safely', () {
      expect(FruitQuality.fromString('BAGUS'), FruitQuality.bagus);
      expect(FruitQuality.fromString('Cukup'), FruitQuality.cukup);
      expect(FruitQuality.fromString('busuk'), FruitQuality.busuk);
      expect(FruitQuality.fromString('invalid_value'), FruitQuality.cukup);
    });
  });
}
