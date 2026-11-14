import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../data/models/prediction_result.dart';
import 'classifier_provider.dart';

enum ScanStatus {
  initial,
  loading,
  success,
  error;
}

class ScanState {
  final ScanStatus status;
  final PredictionResult? result;
  final File? selectedImage;
  final String? errorMessage;

  const ScanState({
    this.status = ScanStatus.initial,
    this.result,
    this.selectedImage,
    this.errorMessage,
  });

  ScanState copyWith({
    ScanStatus? status,
    PredictionResult? result,
    File? selectedImage,
    String? errorMessage,
  }) {
    return ScanState(
      status: status ?? this.status,
      result: result ?? this.result,
      selectedImage: selectedImage ?? this.selectedImage,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class ScanNotifier extends StateNotifier<ScanState> {
  final Ref _ref;
  final ImagePicker _picker = ImagePicker();

  ScanNotifier(this._ref) : super(const ScanState());

  void reset() {
    state = const ScanState();
  }

  Future<void> pickAndClassify(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (picked == null) return;

      final file = File(picked.path);
      state = state.copyWith(
        status: ScanStatus.loading,
        selectedImage: file,
        errorMessage: null,
      );

      final classifier = _ref.read(classifierServiceProvider);
      final prediction = await classifier.predict(file);

      state = state.copyWith(
        status: ScanStatus.success,
        result: prediction,
      );
    } catch (e) {
      state = state.copyWith(
        status: ScanStatus.error,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> classifyFile(File file) async {
    try {
      state = state.copyWith(
        status: ScanStatus.loading,
        selectedImage: file,
        errorMessage: null,
      );

      final classifier = _ref.read(classifierServiceProvider);
      final prediction = await classifier.predict(file);

      state = state.copyWith(
        status: ScanStatus.success,
        result: prediction,
      );
    } catch (e) {
      state = state.copyWith(
        status: ScanStatus.error,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }
}

final scanStateProvider = StateNotifierProvider<ScanNotifier, ScanState>((ref) {
  return ScanNotifier(ref);
});
