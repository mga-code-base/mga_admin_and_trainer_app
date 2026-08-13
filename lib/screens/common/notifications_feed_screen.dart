import 'dart:convert';
import 'package:flutter/material.dart';
import '../../services/notification_service.dart';

class NotificationsFeedScreen extends StatelessWidget {
  const NotificationsFeedScreen({super.key});

  static const Color darkCopper = Color(0xFFD37A3B);

  @override
  Widget build(BuildContext context) {
    final notificationManager = NotificationService();

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F14),
      appBar: AppBar(
        title: const Text(
          'Notification Board Alerts',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF16161F),
        centerTitle: true,
        elevation: 0,

        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: darkCopper),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ValueListenableBuilder<List<Map<String, dynamic>>>(
        valueListenable: notificationManager.notificationsNotifier,
        builder: (context, noticeList, child) {
          if (noticeList.isEmpty) {
            return const Center(
              child: Text(
                'No broadcast alerts logged on this terminal.',
                style: TextStyle(color: Colors.white38, fontSize: 14),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: noticeList.length,
            itemBuilder: (context, index) {
              final notice = noticeList[index];
              final String? base64Image = notice['image'];

              final String displaySender = notice['generatingAdmin'] ?? notice['senderId'] ?? 'System Broadcast';
              final String displayContent = notice['message'] ?? notice['content'] ?? '';

              return Card(
                color: const Color(0xFF16161F),
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),

                  side: BorderSide(color: darkCopper.withOpacity(0.3), width: 1.2),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displaySender,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: darkCopper,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        displayContent,
                        style: const TextStyle(color: Color(0xFFEFEFEF), fontSize: 13, height: 1.4),
                      ),
                      if (base64Image != null && base64Image.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.memory(
                            base64Decode(base64Image),
                            height: 160,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
