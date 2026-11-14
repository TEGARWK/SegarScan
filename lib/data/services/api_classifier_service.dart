import 'dart:io';
import 'package:dio/dio.dart';
import '../models/prediction_result.dart';
import 'classifier_service_interface.dart';

class ApiClassifierService implements IClassifierService {
  final Dio _dio;
  final String baseUrl;

  ApiClassifierService({
    required this.baseUrl,
    Dio? dio,
  }) : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl,
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 10),
                sendTimeout: const Duration(seconds: 10),
              ),
            );

  @override
  Future<PredictionResult> predict(File imageFile) async {
    final fileName = imageFile.path.split(Platform.pathSeparator).last;
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(
        imageFile.path,
        filename: fileName,
      ),
    });

    try {
      final response = await _dio.post(
        '/predict',
        data: formData,
      );

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        return PredictionResult.fromJson(
          response.data as Map<String, dynamic>,
          imagePath: imageFile.path,
        );
      } else {
        throw Exception(
          response.data?['message'] ?? 'Gagal memproses gambar pada server',
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Koneksi timeout. Pastikan server aktif dan terjangkau.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception(
          'Tidak dapat terhubung ke server backend ($baseUrl). Periksa jaringan Wi-Fi.',
        );
      } else if (e.response != null && e.response?.data is Map) {
        final msg = e.response?.data['message'] ?? e.response?.data['detail'];
        throw Exception(msg?.toString() ?? 'Kesalahan respons server: ${e.response?.statusCode}');
      }
      throw Exception('Terjadi kesalahan jaringan: ${e.message}');
    }
  }
}
