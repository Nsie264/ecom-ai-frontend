import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/training_controller.dart';
import '../../services/admin_training_api_service.dart';

class TrainingManagementScreen extends StatelessWidget {
  final TrainingController _trainingController = Get.find<TrainingController>();

  TrainingManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Training Management'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _trainingController.refreshTrainingHistory(),
            tooltip: 'Refresh History',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTrainingButton(),
          const Divider(thickness: 1),
          Expanded(child: _buildTrainingHistoryList()),
        ],
      ),
    );
  }

  Widget _buildTrainingButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      child: Obx(() {
        return ElevatedButton(
          onPressed:
              _trainingController.isRunningJob.value
                  ? null
                  : () => _startTrainingJob(),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            padding: const EdgeInsets.symmetric(vertical: 15),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          child:
              _trainingController.isRunningJob.value
                  ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text('Starting Training...'),
                    ],
                  )
                  : const Text('Run Training Now'),
        );
      }),
    );
  }

  Widget _buildTrainingHistoryList() {
    return Obx(() {
      if (_trainingController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (_trainingController.trainingHistory.isEmpty) {
        return const Center(
          child: Text(
            'No training history available',
            style: TextStyle(fontSize: 16),
          ),
        );
      }

      return ListView.builder(
        itemCount: _trainingController.trainingHistory.length,
        itemBuilder: (context, index) {
          final item = _trainingController.trainingHistory[index];
          return _buildTrainingHistoryItem(item);
        },
      );
    });
  }

  Widget _buildTrainingHistoryItem(TrainingHistoryItem item) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    // Determine the status color based on the status value
    Color statusColor = Colors.grey;
    switch (item.status.toLowerCase()) {
      case 'completed':
        statusColor = Colors.green;
        break;
      case 'failed':
        statusColor = Colors.red;
        break;
      case 'running':
        statusColor = Colors.blue;
        break;
      case 'pending':
        statusColor = Colors.orange;
        break;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ID: ${item.historyId}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    item.status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person, size: 16),
                const SizedBox(width: 4),
                Text('Triggered by: ${item.triggeredBy}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16),
                const SizedBox(width: 4),
                Text('Started: ${dateFormat.format(item.startTime)}'),
              ],
            ),
            if (item.endTime != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.done, size: 16),
                  const SizedBox(width: 4),
                  Text('Completed: ${dateFormat.format(item.endTime!)}'),
                ],
              ),
            ],
            if (item.durationMinutes != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.timer, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Duration: ${item.durationMinutes!.toStringAsFixed(2)} minutes',
                  ),
                ],
              ),
            ],
            // if (item.message != null && item.message!.isNotEmpty) ...[
            //   const SizedBox(height: 8),
            //   Row(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       const Icon(Icons.message, size: 16),
            //       const SizedBox(width: 4),
            //       Expanded(child: Text('Message: ${item.message}')),
            //     ],
            //   ),
            // ],
          ],
        ),
      ),
    );
  }

  void _startTrainingJob() async {
    await _trainingController.runTrainingJob();
  }
}
