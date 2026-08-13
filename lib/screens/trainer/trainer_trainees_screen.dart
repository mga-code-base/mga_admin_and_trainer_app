import 'package:flutter/material.dart';
import '../../models/member_model.dart';
import '../../services/api_service.dart';
import '../../services/auth_cache_service.dart';

class TrainerTraineesScreen extends StatefulWidget {
  const TrainerTraineesScreen({super.key});

  @override
  State<TrainerTraineesScreen> createState() => _TrainerTraineesScreenState();
}

class _TrainerTraineesScreenState extends State<TrainerTraineesScreen> {
  final authCacheService = AuthCacheService();
  late final _apiService = ApiService(authCacheService);
  List<Member> _traineesList = [];
  bool _isLoading = true;

  final Color _themeAccent = Colors.orangeAccent.shade100;

  @override
  void initState() {
    super.initState();
    _loadTrainees();
  }

  Future<void> _loadTrainees() async {
    final String tId = await authCacheService.getCachedTrainerId();
    final data = await _apiService.fetchTraineesByTrainerId(tId);
    setState(() {
      _traineesList = data.map(Member.fromJson).toList();
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
            'My Assigned Trainees',
            style: TextStyle(
              color: _themeAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,

          iconTheme: IconThemeData(color: _themeAccent),
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator(color: _themeAccent))
            : SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: deviceWidth * 0.05, vertical: 12),
            child: _traineesList.isEmpty
                ? const Center(
              child: Text(
                'No active trainees linked to your schedule.',
                style: TextStyle(color: Colors.white60, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            )
                : ListView.builder(
              itemCount: _traineesList.length,
              itemBuilder: (context, index) {
                final student = _traineesList[index];
                final isActive = student.isActive;

                final Color statusColor = isActive ? Colors.greenAccent : Colors.redAccent;
                final Color badgeBgColor = isActive ? Colors.green.withOpacity(0.15) : Colors.red.withOpacity(0.15);

                return Card(
                  color: const Color(0xff1e1e1e),
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 8),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: _themeAccent.withOpacity(0.15), width: 1),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    leading: CircleAvatar(

                      backgroundColor: _themeAccent.withOpacity(0.12),
                      child: Icon(Icons.person, color: _themeAccent),
                    ),
                    title: Text(
                      student.name ?? 'Unknown Member',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        'ID: ${student.memberId} • Ends: ${student.membershipEndDate ?? "N/A"}',
                        style: const TextStyle(color: Colors.white60, fontSize: 13),
                      ),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: badgeBgColor,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: statusColor.withOpacity(0.3), width: 1),
                      ),
                      child: Text(
                        isActive ? 'ACTIVE' : 'INACTIVE',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
