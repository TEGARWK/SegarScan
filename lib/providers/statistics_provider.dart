import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local/database_helper.dart';
import '../data/models/scan_history_item.dart';
import 'history_provider.dart';

class StatisticsData {
  final int totalScans;
  final Map<String, int> qualityCounts;
  final Map<String, int> fruitCounts;
  final double goodPercentage;
  final List<ScanHistoryItem> recentScans;

  const StatisticsData({
    required this.totalScans,
    required this.qualityCounts,
    required this.fruitCounts,
    required this.goodPercentage,
    required this.recentScans,
  });
}

final statisticsProvider = FutureProvider<StatisticsData>((ref) async {
  // Watch historyProvider so stats update automatically whenever a new scan is saved or deleted!
  ref.watch(historyProvider);

  final db = DatabaseHelper.instance;
  final total = await db.getTotalScans();
  final qualityCounts = await db.getQualityCounts();
  final fruitCounts = await db.getFruitTypeCounts();
  final recentScans = await db.getRecentScans(limit: 5);

  final goodCount = qualityCounts['bagus'] ?? 0;
  final goodPercentage = total > 0 ? (goodCount / total) * 100 : 0.0;

  return StatisticsData(
    totalScans: total,
    qualityCounts: qualityCounts,
    fruitCounts: fruitCounts,
    goodPercentage: goodPercentage,
    recentScans: recentScans,
  );
});
