import 'package:flutter/material.dart';
import '../../models/trainer_model.dart';
import '../../services/api_service.dart';
import '../../services/auth_cache_service.dart';

class ApproveTrainersScreen extends StatefulWidget {
  const ApproveTrainersScreen({super.key});

  @override
  State<ApproveTrainersScreen> createState() => _ApproveTrainersScreenState();
}

class _ApproveTrainersScreenState extends State<ApproveTrainersScreen> {
  final authCacheService = AuthCacheService();
  late final _apiService = ApiService(authCacheService);
  List<Trainer> _pendingTrainersList = [];
  bool _isLoading = true;

  final Color _themeAccent = Colors.tealAccent.shade200;

  @override
  void initState() {
    super.initState();
    _loadInactiveTrainers();
  }

  Future<void> _loadInactiveTrainers() async {
    setState(() => _isLoading = true);
    final data = await _apiService.fetchInactiveTrainers();
    setState(() {
      _pendingTrainersList = data.map(Trainer.fromJson).toList();
      _isLoading = false;
    });
  }

  void _handleApproveAction(String trainerId, String name) async {
    setState(() => _isLoading = true);
    bool success = await _apiService.approveTrainerAccount(trainerId);

    if (success) {
      _showFeedbackSnackBar('$name profile has been approved successfully!', isError: false);
      _loadInactiveTrainers();
    } else {
      _showFeedbackSnackBar('Failed to authorize $name profile update.', isError: true);
      setState(() => _isLoading = false);
    }
  }

  void _handleDeleteAction(String trainerId, String name) async {
    setState(() => _isLoading = true);
    bool success = await _apiService.deleteTrainerAccount(trainerId);

    if (success) {
      _showFeedbackSnackBar('$name profile has been purged from system registries.', isError: false);
      _loadInactiveTrainers();
    } else {
      _showFeedbackSnackBar('Failed to complete account purge command.', isError: true);
      setState(() => _isLoading = false);
    }
  }

  void _showFeedbackSnackBar(String msg, {required bool isError}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double deviceHeight = MediaQuery.of(context).size.height;

    return Theme(
        data: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: const Color(0xFF0F0F14),
          appBarTheme: AppBarTheme(
            backgroundColor: const Color(0xFF16161F),
            elevation: 0,
            centerTitle: true,
            titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _themeAccent),
          ),
        ),
        child: Scaffold(
            appBar: AppBar(
              title: const Text('Pending Trainer Profiles'),
              centerTitle: true,
              iconTheme: IconThemeData(color: _themeAccent),
            ),
            body: _isLoading
                ? Center(child: CircularProgressIndicator(color: _themeAccent))
                : SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: deviceWidth * 0.05, vertical: deviceHeight * 0.015),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(
                  'Awaiting Authorizations (${_pendingTrainersList.length} profiles)',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  SizedBox(height: deviceHeight * 0.02),
                      Expanded(
                        child: _pendingTrainersList.isEmpty
                            ? const Center(
                          child: Text(
                            'No new trainer registration logs require audit.',
                            style: TextStyle(color: Colors.white38, fontSize: 14),
                          ),
                        )
                            : ListView.builder(
                          itemCount: _pendingTrainersList.length,
                          itemBuilder: (context, index) {
                            final trainer = _pendingTrainersList[index];
                            final String tId = trainer.trainerId;
                            final String trainerName = trainer.name ?? 'Unknown Coach';

                            return Card(
                              color: const Color(0xFF16161F),
                              elevation: 4,
                              margin: EdgeInsets.symmetric(vertical: deviceHeight * 0.01),

                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(color: _themeAccent.withOpacity(0.6), width: 1.5),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            trainerName,
                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: _themeAccent),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),

                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: _themeAccent.withOpacity(0.12),
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(color: _themeAccent.withOpacity(0.4)),
                                          ),
                                          child: Text(
                                            'ID: $tId',
                                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _themeAccent),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Text('📧 Email: ${trainer.emailAddress ?? "N/A"}', style: const TextStyle(color: Colors.white60, fontSize: 13)),
                                    const SizedBox(height: 4),
                                    Text('📱 Mobile: ${trainer.mobileNumber ?? "N/A"}', style: const TextStyle(color: Colors.white60, fontSize: 13)),

                                    Divider(height: 24, color: _themeAccent.withOpacity(0.2), thickness: 1),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF1A1315),
                                            foregroundColor: Colors.redAccent,
                                            elevation: 0,
                                            side: const BorderSide(color: Colors.redAccent),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                          ),
                                          onPressed: () => _handleDeleteAction(tId, trainerName),
                                          icon: const Icon(Icons.delete_outline, size: 16),
                                          label: const Text('Purge', style: TextStyle(fontSize: 13)),
                                        ),
                                        const SizedBox(width: 12),
                                        ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: _themeAccent,
                                            foregroundColor: Colors.black,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                          ),
                                          onPressed: () => _handleApproveAction(tId, trainerName),
                                          icon: const Icon(Icons.check, size: 16, color: Colors.black),
                                          label: const Text('Approve Entry', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
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
                    ],
                  ),
                ),
            ),
        ),
    );
  }
}
