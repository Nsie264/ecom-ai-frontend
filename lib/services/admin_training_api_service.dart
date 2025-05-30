import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../utils/http_client.dart';

/// Model class for a training job result
class TrainingJobResult {
  final bool success;
  final String message;
  final int historyId;
  final double executionTime;

  TrainingJobResult({
    required this.success,
    required this.message,
    required this.historyId,
    required this.executionTime,
  });

  factory TrainingJobResult.fromJson(Map<String, dynamic> json) {
    return TrainingJobResult(
      success: json['success'],
      message: json['message'] ?? '',
      historyId: json['history_id'],
      executionTime: json['execution_time']?.toDouble() ?? 0.0,
    );
  }
}

/// Model class for a training job history item
class TrainingHistoryItem {
  final int historyId;
  final DateTime startTime;
  final DateTime? endTime;
  final String status;
  final String triggeredBy;
  final String? message;
  final double? durationMinutes;

  TrainingHistoryItem({
    required this.historyId,
    required this.startTime,
    this.endTime,
    required this.status,
    required this.triggeredBy,
    this.message,
    this.durationMinutes,
  });

  factory TrainingHistoryItem.fromJson(Map<String, dynamic> json) {
    return TrainingHistoryItem(
      historyId: json['history_id'],
      startTime: DateTime.parse(json['start_time']),
      endTime:
          json['end_time'] != null ? DateTime.parse(json['end_time']) : null,
      status: json['status'],
      triggeredBy: json['triggered_by'],
      message: json['message'],
      durationMinutes: json['duration_minutes']?.toDouble(),
    );
  }
}

/// Model class for pagination information
class PaginationInfo {
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;

  PaginationInfo({
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      total: json['total'],
      page: json['page'],
      pageSize: json['page_size'],
      totalPages: json['total_pages'],
    );
  }
}

/// Model class for training history response
class TrainingHistoryResponse {
  final bool success;
  final String? message;
  final List<TrainingHistoryItem> history;
  final int totalCount;

  TrainingHistoryResponse({
    required this.success,
    this.message,
    required this.history,
    required this.totalCount,
  });

  factory TrainingHistoryResponse.fromJson(Map<String, dynamic> json) {
    return TrainingHistoryResponse(
      success: json['success'],
      message: json['message'],
      history:
          (json['history'] as List)
              .map((item) => TrainingHistoryItem.fromJson(item))
              .toList(),
      totalCount: json['total_count'],
    );
  }
}

/// Service to interact with the recommendation training API endpoints
class AdminTrainingApiService {
  final HttpClient _httpClient;

  /// Constructor that initializes the HttpClient with the base URL
  AdminTrainingApiService() : _httpClient = HttpClient(ApiConfig.baseUrl);

  /// Starts a recommendation model training job
  ///
  /// Returns a [TrainingJobResult] with information about the started job
  /// Throws [DioException] if the request fails
  Future<TrainingJobResult> startTrainingJob() async {
    try {
      final response = await _httpClient.post('/recommendations/train');

      if (response.statusCode == 200 && response.data['success'] == true) {
        // The job_result object contains the details about the training job
        return TrainingJobResult.fromJson(response.data['job_result']);
      } else {
        throw DioException(
          requestOptions: RequestOptions(path: '/recommendations/train'),
          error:
              'Failed to start training job: ${response.data['message'] ?? 'Unknown error'}',
          response: response,
        );
      }
    } on DioException {
      rethrow; // Re-throw Dio exceptions for handling at a higher level
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(path: '/recommendations/train'),
        error: 'Unexpected error: $e',
      );
    }
  }

  /// Gets the history of recommendation model training jobs
  ///
  /// [page] - The page number for pagination (default: 1)
  /// [pageSize] - The number of items per page (default: 10, max: 50)
  ///
  /// Returns a [TrainingHistoryResponse] with the history items and pagination info
  /// Throws [DioException] if the request fails
  Future<TrainingHistoryResponse> getTrainingHistory({
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final response = await _httpClient.get(
        '/recommendations/training-history',
        queryParameters: {'page': page, 'page_size': pageSize},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return TrainingHistoryResponse.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: RequestOptions(
            path: '/recommendations/training-history',
          ),
          error:
              'Failed to get training history: ${response.data['message'] ?? 'Unknown error'}',
          response: response,
        );
      }
    } on DioException {
      rethrow; // Re-throw Dio exceptions for handling at a higher level
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(
          path: '/recommendations/training-history',
        ),
        error: 'Unexpected error: $e',
      );
    }
  }
}
