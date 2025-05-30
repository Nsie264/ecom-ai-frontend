import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../services/admin_training_api_service.dart';

/// Controller for managing training-related operations and state
class TrainingController extends GetxController {
  // Service for API operations
  final AdminTrainingApiService _trainingService = AdminTrainingApiService();

  // Observable state variables
  final RxBool isLoading = false.obs;
  final RxBool isRunningJob = false.obs;
  final RxList<TrainingHistoryItem> trainingHistory =
      <TrainingHistoryItem>[].obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    fetchTrainingHistory();
    super.onInit();
  }

  /// Run a new training job
  ///
  /// Returns the job result if successful, null otherwise
  /// Updates the [isRunningJob] state during execution
  Future<TrainingJobResult?> runTrainingJob() async {
    if (isRunningJob.value)
      return null; // Prevent multiple concurrent job starts

    isRunningJob.value = true;
    errorMessage.value = '';
    TrainingJobResult? result;

    try {
      result = await _trainingService.startTrainingJob();

      // On success, refresh the training history to include the new job
      await fetchTrainingHistory();

      // Show success message
      Get.snackbar(
        'Training Job Started',
        'Job ID: ${result.historyId}\nExecution Time: ${result.executionTime.toStringAsFixed(2)} seconds',
        snackPosition: SnackPosition.BOTTOM,
      );

      return result;
    } on DioException catch (e) {
      errorMessage.value = 'Error starting training job: ${e.error}';
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    } catch (e) {
      errorMessage.value = 'Unexpected error: $e';
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    } finally {
      isRunningJob.value = false;
    }
  }

  /// Fetch all training history items
  ///
  /// Updates the [trainingHistory] and [isLoading] states
  Future<void> fetchTrainingHistory() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // Setting a large page size to get all records without pagination
      // as requested in the specifications
      final response = await _trainingService.getTrainingHistory(
        pageSize: 100, // Use a large value to get all items at once
      );

      if (response.success) {
        trainingHistory.value = response.history;
      } else {
        errorMessage.value =
            'Failed to fetch training history: ${response.message ?? 'Unknown error'}';
        Get.snackbar(
          'Error',
          errorMessage.value,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } on DioException catch (e) {
      errorMessage.value = 'Error fetching training history: ${e.error}';
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      errorMessage.value = 'Unexpected error: $e';
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh training history data
  ///
  /// Convenience method that can be called from UI to refresh data
  Future<void> refreshTrainingHistory() => fetchTrainingHistory();
}
