import 'package:flutter/material.dart';
import '../../core/config/app_routes.dart';
import 'package:mga_admin_and_trainer_app/services/auth_cache_service.dart';
import '../../services/notification_service.dart';
import '../../services/websocket_service.dart';

class TrainerHomeScreen extends StatefulWidget {
  const TrainerHomeScreen({super.key});

  @override
  State<TrainerHomeScreen> createState() => _TrainerHomeScreenState();
}

class _TrainerHomeScreenState extends State<TrainerHomeScreen> {
  final NotificationService _notificationManager = NotificationService();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double deviceHeight = MediaQuery.of(context).size.height;

    return Theme(
        data: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: const Color(0xff121212),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xff1e1e1e),
            elevation: 0,
          ),
        ),
        child: Scaffold(
          appBar: AppBar(
            title: const Text(
              'Trainer Console',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
            centerTitle: true,
            leadingWidth: 70,
            leading: ValueListenableBuilder<int>(
              valueListenable: _notificationManager.unreadCountNotifier,
              builder: (context, unreadCount, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_none_outlined, color: Colors.white, size: 26),
                      onPressed: () async {
                        await WebSocketService().syncMissedNotificationsHistory();
                        _notificationManager.markAllAsRead();

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
            actions: [
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.redAccent),
                onPressed: () async {
                  WebSocketService().disconnectWebSocket();
                  await AuthCacheService().clearSession();
                  if (!context.mounted) return;
                  Navigator.pushReplacementNamed(context, AppRoutes.login);
                },
              )
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: deviceWidth * 0.05, vertical: deviceHeight * 0.02),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Expanded(
                    child: Center(
                      child: GridView.count(
                        shrinkWrap: true,
                        physics: const ClampingScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        children: [
                          _buildMenuTile(
                            title: 'My Details',
                            icon: Icons.account_box,
                            color: Colors.blueAccent.shade100,
                            onTap: () => Navigator.pushNamed(context, AppRoutes.trainerDetails),
                          ),
                          _buildMenuTile(
                            title: 'My Branch',
                            icon: Icons.storefront,
                            color: Colors.tealAccent.shade200,
                            onTap: () => Navigator.pushNamed(context, AppRoutes.trainerBranch),
                          ),
                          _buildMenuTile(
                            title: 'My Trainees',
                            icon: Icons.assignment_ind,
                            color: Colors.orangeAccent.shade100,
                            onTap: () => Navigator.pushNamed(context, AppRoutes.trainerTrainees),
                          ),
                          _buildMenuTile(
                            title: 'Workout Records',
                            icon: Icons.analytics_outlined,
                            color: Colors.purpleAccent.shade100,
                            onTap: () => Navigator.pushNamed(context, AppRoutes.traineeProgress),
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

  Widget _buildMenuTile({required String title, required IconData icon, required Color color, required VoidCallback onTap}) {
    return Card(
      color: const Color(0xff1e1e1e),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        splashColor: color.withOpacity(0.15),
        highlightColor: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
