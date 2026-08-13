import 'package:flutter/material.dart';
import '../../core/config/app_routes.dart';
import '../../services/auth_cache_service.dart';
import '../../services/notification_service.dart';
import '../../services/websocket_service.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double deviceHeight = MediaQuery.of(context).size.height;
    final notificationManager = NotificationService();

    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F0F14),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF16161F),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF16161F),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Colors.white10, width: 1),
          ),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Console'),
          centerTitle: true,
          leadingWidth: 110,
          leading: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.campaign, color: Color(0xFF4CD964), size: 26),
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
                    child: GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      physics: const ClampingScrollPhysics(),
                      children: [
                        _buildMenuTile(
                          title: 'My Branch',
                          icon: Icons.storefront,
                          color: Colors.blueAccent.shade100,
                          onTap: () => Navigator.pushNamed(context, AppRoutes.myBranchDetails),
                        ),
                        _buildMenuTile(
                          title: 'Approve Trainers',
                          icon: Icons.badge,
                          color: Colors.tealAccent.shade200,
                          onTap: () => Navigator.pushNamed(context, AppRoutes.approveTrainers),
                        ),
                        _buildMenuTile(
                          title: 'Approve Member',
                          icon: Icons.person_add,
                          color: Colors.orangeAccent.shade200,
                          onTap: () => Navigator.pushNamed(context, AppRoutes.approveMembers),
                        ),
                        _buildMenuTile(
                          title: 'Equipments',
                          icon: Icons.fitness_center,
                          color: Colors.purpleAccent.shade100,
                          onTap: () => Navigator.pushNamed(context, AppRoutes.branchEquipments),
                        ),
                        _buildMenuTile(
                          title: 'Get Member',
                          icon: Icons.badge_outlined,

                          color: Colors.redAccent.shade100,
                          onTap: () => Navigator.pushNamed(context, AppRoutes.getMember),
                        ),
                        _buildMenuTile(
                          title: 'Deactivate Trainer',
                          icon: Icons.block,

                          color: const Color(0xFFD63031),
                          onTap: () => Navigator.pushNamed(context, AppRoutes.deactivateTrainer),
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

  Widget _buildMenuTile({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 38, color: color),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFFEFEFEF)),
            ),
          ],
        ),
      ),
    );
  }
}
