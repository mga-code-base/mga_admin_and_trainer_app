import 'package:flutter/material.dart';
import '../../models/trainer_model.dart';
import '../../services/api_service.dart';
import '../../services/auth_cache_service.dart';

class TrainerDetailsScreen extends StatefulWidget {
  const TrainerDetailsScreen({super.key});

  @override
  State<TrainerDetailsScreen> createState() => _TrainerDetailsScreenState();
}

class _TrainerDetailsScreenState extends State<TrainerDetailsScreen> {
  final authCacheService = AuthCacheService();
  late final _apiService = ApiService(authCacheService);
  Trainer? _trainer;
  bool _isLoading = true;

  final Color _themeAccent = Colors.blueAccent.shade100;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final String tId = await authCacheService.getCachedTrainerId();
    final data = await _apiService.fetchTrainerProfileDetails(tId);
    setState(() {
      _trainer = data == null ? null : Trainer.fromJson(data);
      _isLoading = false;
    });
  }
  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;

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
          title: Text(
            'My Profile Specs',
            style: TextStyle(color: _themeAccent, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          iconTheme: IconThemeData(color: _themeAccent),
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator(color: _themeAccent))
            : SafeArea(
          child: Padding(
            padding: EdgeInsets.all(deviceWidth * 0.06),
            child: _trainer == null
                ? const Center(
              child: Text(
                'Profile records unavailable.',
                style: TextStyle(color: Colors.white60, fontSize: 16),
              ),
            )
                : Center(
              child: Card(
                color: const Color(0xff1e1e1e),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: _themeAccent.withOpacity(0.6), width: 1.5),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          _trainer!.name ?? 'Unknown Coach',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _themeAccent),
                        ),
                      ),

                      Divider(height: 32, color: _themeAccent, thickness: 1),
                      _buildRow(Icons.badge, 'Trainer ID', _trainer!.trainerId),
                      const SizedBox(height: 16),
                      _buildRow(Icons.person, 'Username', _trainer!.username),
                      const SizedBox(height: 16),
                      _buildRow(Icons.phone, 'Mobile', _trainer!.mobileNumber),
                      const SizedBox(height: 16),
                      _buildRow(Icons.email, 'Email Address', _trainer!.emailAddress),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRow(IconData icon, String label, String? val) {
    return Row(
      children: [
        Icon(icon, size: 20, color: _themeAccent),
        const SizedBox(width: 14),
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white60),
        ),
        Expanded(
          child: Text(
            val ?? 'N/A',
            style: const TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
