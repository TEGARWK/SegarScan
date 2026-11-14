import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/services/api_classifier_service.dart';
import '../data/services/classifier_service_interface.dart';
import '../data/services/mock_classifier_service.dart';

/// Mode inferensi: 'mock' atau 'api'
final inferenceModeProvider = StateProvider<String>((ref) => 'mock');

/// Endpoint API backend tim CV
final apiBaseUrlProvider = StateProvider<String>((ref) => 'http://192.168.1.10:8000');

/// Provider IClassifierService dinamis
final classifierServiceProvider = Provider<IClassifierService>((ref) {
  final mode = ref.watch(inferenceModeProvider);
  final baseUrl = ref.watch(apiBaseUrlProvider);

  if (mode == 'api') {
    return ApiClassifierService(baseUrl: baseUrl);
  }
  return MockClassifierService();
});
