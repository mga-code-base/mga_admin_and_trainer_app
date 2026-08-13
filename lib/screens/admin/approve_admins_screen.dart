import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/auth_cache_service.dart';

class ApproveAdminsScreen extends StatefulWidget {
  const ApproveAdminsScreen({super.key});

  @override
  State<ApproveAdminsScreen> createState() => _ApproveAdminsScreenState();
}

class _ApproveAdminsScreenState extends State<ApproveAdminsScreen> {
  final authCacheService = AuthCacheService();
  late final apiService = ApiService(authCacheService);
  List<Map<String, dynamic>> _inactiveAdmins = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialAdminRecords();
  }

  Future<void> _loadInitialAdminRecords() async {
    setState(() => _isLoading = true);
    final list = await apiService.fetchInactiveAdmins();
    setState(() {
      _inactiveAdmins = list;
      _isLoading = false;
    });
  }

  void _executeApprovalAction(int index, String adminId) async {
    bool success = await apiService.approveAdminUser(adminId);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Admin successfully activated and saved!'),
          duration: Duration(seconds: 2),
        ),
      );

      setState(() {
        _inactiveAdmins.removeAt(index);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to complete verification. Backend error occurred.')),
      );
    }
  }

  void _executeDeleteAction(int index, String adminId) async {
    bool success = await apiService.deleteAdminMicroservice(adminId);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Admin record completely removed from database.'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.redAccent,
        ),
      );

      setState(() {
        _inactiveAdmins.removeAt(index);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete admin profile. Backend logic rejected.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
          elevation: 2,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(title: const Text('Approve Admins'), centerTitle: true),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _inactiveAdmins.isEmpty
            ? const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.done_all, size: 48, color: Colors.greenAccent),
              SizedBox(height: 12),
              Text(
                'No pending admin profiles requiring approvals.',
                style: TextStyle(color: Colors.white54, fontSize: 16),
              ),
            ],
          ),
        )
            : ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: _inactiveAdmins.length,
          itemBuilder: (context, idx) {
            final admin = _inactiveAdmins[idx];
            final String adminId = admin['adminId']?.toString() ?? '0';

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            admin['name'] ?? 'Unknown Admin',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const SizedBox(height: 4),
                          Text('User: ${admin['username']}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                          Text('Phone: ${admin['mobileNumber']}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                          Text('Email: ${admin['emailAddress']}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade700,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(110, 36),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () => _executeApprovalAction(idx, adminId),
                          icon: const Icon(Icons.check, size: 14),
                          label: const Text('Approve', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade800,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(110, 36),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () => _executeDeleteAction(idx, adminId),
                          icon: const Icon(Icons.delete_outline, size: 14),
                          label: const Text('Delete', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
