import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/classifier_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late TextEditingController _urlController;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: ref.read(apiBaseUrlProvider));
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(inferenceModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pengaturan & Info',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        children: [
          // Section Mode Inferensi
          const Text(
            'Mode Inferensi Model',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFF0F0F0)),
            ),
            child: RadioGroup<String>(
              groupValue: mode,
              onChanged: (val) {
                if (val != null) {
                  ref.read(inferenceModeProvider.notifier).state = val;
                }
              },
              child: const Column(
                children: [
                  RadioListTile<String>(
                    title: Text('Mode Mock (Offline Demo)'),
                    subtitle: Text('Simulasi hasil klasifikasi tanpa perlu server backend.'),
                    value: 'mock',
                    activeColor: AppColors.primaryGreen,
                  ),
                  Divider(height: 1, color: Color(0xFFEEEEEE)),
                  RadioListTile<String>(
                    title: Text('Mode REST API (FastAPI Server)'),
                    subtitle: Text('Mengirim citra ke endpoint server model CV asli.'),
                    value: 'api',
                    activeColor: AppColors.primaryGreen,
                  ),
                ],
              ),
            ),
          ),

          if (mode == 'api') ...[
            const SizedBox(height: 20),
            const Text(
              'Konfigurasi Endpoint API',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFF0F0F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _urlController,
                    decoration: const InputDecoration(
                      labelText: 'Base URL API',
                      hintText: 'http://192.168.1.10:8000',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(14)),
                      ),
                      prefixIcon: Icon(Icons.link_rounded),
                    ),
                    onChanged: (val) {
                      ref.read(apiBaseUrlProvider.notifier).state = val.trim();
                    },
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Pastikan perangkat smartphone dan komputer backend berada di jaringan Wi-Fi yang sama.',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 28),

          // Info Aplikasi & Tubes
          const Text(
            'Tentang Aplikasi',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFF0F0F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.energy_savings_leaf_rounded,
                        color: AppColors.primaryGreen,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SegarScan',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Versi 1.0.0 (Tugas Besar Computer Vision)',
                          style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Aplikasi sortir mutu buah berbasis citra digital yang dirancang untuk mempermudah identifikasi kesegaran buah secara cepat, objektif, dan otomatis.',
                  style: TextStyle(fontSize: 13, height: 1.4, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFEEEEEE)),
                const SizedBox(height: 12),
                const Text(
                  'Buah yang Didukung Saat Ini:',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  '• Apel  • Jeruk  • Pisang  • Mangga  • Tomat',
                  style: TextStyle(fontSize: 13, color: AppColors.primaryDark),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
