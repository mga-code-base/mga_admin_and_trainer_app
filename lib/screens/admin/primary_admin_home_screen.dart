import 'package:flutter/material.dart';
import '../../core/config/app_routes.dart';
import 'package:mga_admin_and_trainer_app/services/auth_cache_service.dart';
import 'package:mga_admin_and_trainer_app/services/notification_service.dart';
import 'package:mga_admin_and_trainer_app/services/websocket_service.dart';

class PrimaryAdminHomeScreen extends StatelessWidget {
  const PrimaryAdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double deviceHeight = MediaQuery.of(context).size.height;
    final notificationManager = NotificationService();

    return Theme(
        data: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: const Color(0xFF121212),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF1E1E1E),
            elevation: 0,
            centerTitle: true,
            titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          cardTheme: const CardThemeData(
            color: Color(0xFF1E1E1E),
            elevation: 3,
          ),
        ),
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Primary Admin'),
            leadingWidth: 110,
            leading: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.campaign, color: Colors.cyanAccent, size: 26),
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.publishNotification),
                ),
                ValueListenableBuilder<int>(
                  valueListenable: notificationManager.unreadCountNotifier,
                  builder: (context, unreadCount, child) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        IconButton(

                          icon: const Icon(Icons.notifications_none_outlined, color: Color(0xFFD37A3B), size: 26),
                          onPressed: () async {
                            await WebSocketService().syncMissedNotificationsHistory();
                            notificationManager.markAllAsRead();

                            if (!context.mounted) return;
                            Navigator.pushNamed(context, AppRoutes.notificationsFeed);
                          },
                        ),
                        if (unreadCount > 0)
                          Positioned(
                            right: 4,
                            top: 4,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.redAccent,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                              child: Text(
                                '$unreadCount',
                                style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.redAccent),
                onPressed: () async {
                  WebSocketService().disconnectWebSocket();
                  await AuthCacheService().clearSession();
                  if (!context.mounted) return;
                  Navigator.pushReplacementNamed(context, AppRoutes.login);
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: deviceWidth * 0.05, vertical: deviceHeight * 0.02),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  Expanded(
                    child: Center(
                      child: ListView(
                        shrinkWrap: true,
                        physics: const ClampingScrollPhysics(),
                        children: [
                          _buildMenuListRow(
                            context: context,
                            title: 'Approvals',
                            subtitle: 'Manage pending user registration profiles',
                            icon: Icons.assignment_turned_in,
                            color: Colors.teal.shade300,
                            deviceHeight: deviceHeight,
                            onTap: () => Navigator.pushNamed(context, AppRoutes.approveAdmins),
                          ),
                          _buildMenuListRow(
                            context: context,
                            title: 'All Branches',
                            subtitle: 'Inspect location operations and assets logs',
                            icon: Icons.location_city,
                            color: Colors.blue.shade300,
                            deviceHeight: deviceHeight,
                            onTap: () => Navigator.pushNamed(context, AppRoutes.allBranches),
                          ),
                          _buildMenuListRow(
                            context: context,
                            title: 'Grievances',
                            subtitle: 'Track active branch customer support tickets',
                            icon: Icons.gavel,
                            color: Colors.red.shade300,
                            deviceHeight: deviceHeight,
                            onTap: () => Navigator.pushNamed(context, AppRoutes.activeGrievances),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
    );
  }

  Widget _buildMenuListRow({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required double deviceHeight,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: deviceHeight * 0.012),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: deviceHeight * 0.018, horizontal: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 28, color: color),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white70),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade600),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
