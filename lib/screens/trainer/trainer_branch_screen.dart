import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/auth_cache_service.dart';

class TrainerBranchScreen extends StatefulWidget {
  const TrainerBranchScreen({super.key});

  @override
  State<TrainerBranchScreen> createState() => _TrainerBranchScreenState();
}

class _TrainerBranchScreenState extends State<TrainerBranchScreen> {
  final authCacheService = AuthCacheService();
  late final _apiService = ApiService(authCacheService);
  Map<String, dynamic>? _branchData;
  bool _isLoading = true;

  final Color _themeAccent = Colors.tealAccent.shade200;

  @override
  void initState() {
    super.initState();
    _loadBranch();
  }

  Future<void> _loadBranch() async {
    final String tId = await authCacheService.getCachedTrainerId();
    final data = await _apiService.fetchBranchDetailsByTrainerId(tId);
    setState(() {
      _branchData = data;
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
            'My Assigned Branch',
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
            child: _branchData == null
                ? const Center(
              child: Text(
                'No explicit branch linked to this trainer account.',
                textAlign: TextAlign.center,
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
                          _branchData!['name'] ?? 'Unnamed Hub',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _themeAccent),
                        ),
                      ),

                      Divider(height: 32, color: _themeAccent, thickness: 1),
                      _buildRow(Icons.tag, 'Branch ID', _branchData!['branchId']?.toString()),
                      const SizedBox(height: 16),
                      _buildRow(Icons.location_on, 'Address', _branchData!['address']),
                      const SizedBox(height: 16),
                      _buildRow(Icons.location_city, 'City Location', _branchData!['city']),
                      const SizedBox(height: 16),
                      _buildRow(Icons.pin_drop, 'Pincode Zone', _branchData!['pincode']?.toString()),
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
      crossAxisAlignment: CrossAxisAlignment.start,
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
