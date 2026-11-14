import 'dart:io';
import '../models/prediction_result.dart';

abstract class IClassifierService {
  /// Predicts fruit type and quality from an image file
  Future<PredictionResult> predict(File imageFile);
}
