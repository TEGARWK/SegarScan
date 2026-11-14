import 'dart:io';
import 'dart:math';
import '../models/fruit_quality.dart';
import '../models/prediction_result.dart';
import 'classifier_service_interface.dart';

class MockClassifierService implements IClassifierService {
  final Random _random = Random();

  final List<String> _fruits = ['apel', 'jeruk', 'pisang', 'mangga', 'tomat'];

  @override
  Future<PredictionResult> predict(File imageFile) async {
    // Berikan durasi wajar (2.5 detik) agar animasi inspeksi Pak Segar & tahapan AI dinikmati user
    await Future.delayed(const Duration(milliseconds: 2500));

    final fruit = _fruits[_random.nextInt(_fruits.length)];
    // Bias towards 'bagus' (60%) and 'cukup' (25%) for realistic demonstration
    final roll = _random.nextDouble();
    final FruitQuality quality;
    if (roll < 0.60) {
      quality = FruitQuality.bagus;
    } else if (roll < 0.85) {
      quality = FruitQuality.cukup;
    } else {
      quality = FruitQuality.busuk;
    }

    final confidence = double.parse((0.82 + _random.nextDouble() * 0.16).toStringAsFixed(2));
    final remaining = double.parse((1.0 - confidence).toStringAsFixed(2));
    final p2 = double.parse((remaining * 0.7).toStringAsFixed(2));
    final p3 = double.parse((remaining - p2).toStringAsFixed(2));

    final probabilities = <String, double>{
      'bagus': quality == FruitQuality.bagus ? confidence : p2,
      'cukup': quality == FruitQuality.cukup ? confidence : (quality == FruitQuality.bagus ? p3 : p2),
      'busuk': quality == FruitQuality.busuk ? confidence : p3,
    };

    return PredictionResult(
      success: true,
      fruit: fruit,
      quality: quality,
      confidence: confidence,
      probabilities: probabilities,
      inferenceTimeMs: 140 + _random.nextInt(60),
      imagePath: imageFile.path,
    );
  }
}
