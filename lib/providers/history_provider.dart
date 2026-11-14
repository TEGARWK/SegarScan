import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local/database_helper.dart';
import '../data/models/prediction_result.dart';
import '../data/models/scan_history_item.dart';
import 'classifier_provider.dart';

class HistoryState {
  final List<ScanHistoryItem> items;
  final bool isLoading;
  final String? selectedQualityFilter;
  final String? selectedFruitFilter;

  const HistoryState({
    this.items = const [],
    this.isLoading = false,
    this.selectedQualityFilter,
    this.selectedFruitFilter,
  });

  HistoryState copyWith({
    List<ScanHistoryItem>? items,
    bool? isLoading,
    String? Function()? selectedQualityFilter,
    String? Function()? selectedFruitFilter,
  }) {
    return HistoryState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      selectedQualityFilter: selectedQualityFilter != null
          ? selectedQualityFilter()
          : this.selectedQualityFilter,
      selectedFruitFilter: selectedFruitFilter != null
          ? selectedFruitFilter()
          : this.selectedFruitFilter,
    );
  }
}

class HistoryNotifier extends StateNotifier<HistoryState> {
  final Ref _ref;
  final DatabaseHelper _db = DatabaseHelper.instance;

  HistoryNotifier(this._ref) : super(const HistoryState()) {
    loadHistory();
  }

  Future<void> loadHistory() async {
    state = state.copyWith(isLoading: true);
    try {
      final data = await _db.getAllHistory(
        quality: state.selectedQualityFilter,
        fruit: state.selectedFruitFilter,
      );
      state = state.copyWith(items: data, isLoading: false);
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  void filterByQuality(String? quality) {
    state = state.copyWith(selectedQualityFilter: () => quality);
    loadHistory();
  }

  void filterByFruit(String? fruit) {
    state = state.copyWith(selectedFruitFilter: () => fruit);
    loadHistory();
  }

  Future<void> savePrediction({
    required PredictionResult prediction,
    required String imagePath,
  }) async {
    final mode = _ref.read(inferenceModeProvider);
    final historyItem = ScanHistoryItem.fromPrediction(
      prediction: prediction,
      imagePath: imagePath,
      source: mode,
    );
    await _db.insertScan(historyItem);
    await loadHistory();
  }

  Future<void> deleteItem(int id) async {
    await _db.deleteScan(id);
    await loadHistory();
  }

  Future<void> clearAll() async {
    await _db.clearAll();
    await loadHistory();
  }
}

final historyProvider =
    StateNotifierProvider<HistoryNotifier, HistoryState>((ref) {
  return HistoryNotifier(ref);
});
