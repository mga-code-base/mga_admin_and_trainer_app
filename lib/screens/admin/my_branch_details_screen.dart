import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/auth_cache_service.dart';

class MyBranchDetailsScreen extends StatefulWidget {
  const MyBranchDetailsScreen({super.key});

  @override
  State<MyBranchDetailsScreen> createState() => _MyBranchDetailsScreenState();
}

class _MyBranchDetailsScreenState extends State<MyBranchDetailsScreen> {
  final authCacheService = AuthCacheService();
  late final _apiService = ApiService(authCacheService);
  Map<String, dynamic>? _branchData;
  bool _isLoading = true;

  final Color _themeAccent = Colors.blueAccent.shade100;

  @override
  void initState() {
    super.initState();
    _loadBranchProfile();
  }

  Future<void> _loadBranchProfile() async {
    setState(() => _isLoading = true);
    final String activeAdminId = await authCacheService.getCachedAdminId();
    final data = await _apiService.fetchBranchDetailsByAdminId(activeAdminId);

    setState(() {
      _branchData = data;
      _isLoading = false;
    });
  }
  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double deviceHeight = MediaQuery.of(context).size.height;

    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F0F14),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF16161F),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'My Branch Hub',
            style: TextStyle(color: _themeAccent, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          iconTheme: IconThemeData(color: _themeAccent),
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator(color: _themeAccent))
            : SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: deviceWidth * 0.05, vertical: deviceHeight * 0.02),
            child: _branchData == null
                ? const Center(
              child: Text(
                'No explicit branch linked to this administrator account.',
                style: TextStyle(color: Colors.white38, fontSize: 15),
                textAlign: TextAlign.center,
              ),
            )
                : Center(

              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF16161F),
                  borderRadius: BorderRadius.circular(16),

                  border: Border.all(color: _themeAccent.withOpacity(0.6), width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            _branchData!['name'] ?? 'Unnamed Location',
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _themeAccent),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: _themeAccent.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: _themeAccent.withOpacity(0.4)),
                          ),
                          child: Text(
                            'ID: ${_branchData!['branchId'] ?? 'N/A'}',
                            style: TextStyle(fontWeight: FontWeight.bold, color: _themeAccent, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: deviceHeight * 0.02),

                    Divider(color: _themeAccent, thickness: 1),
                    SizedBox(height: deviceHeight * 0.02),
                    _buildProfileRow(Icons.location_on, 'Address', _branchData!['address']),
                    SizedBox(height: deviceHeight * 0.02),
                    _buildProfileRow(Icons.location_city, 'City', _branchData!['city']),
                    SizedBox(height: deviceHeight * 0.02),
                    _buildProfileRow(Icons.pin_drop, 'Pincode', _branchData!['pincode']?.toString()),
                    SizedBox(height: deviceHeight * 0.02),
                    _buildProfileRow(
                      Icons.badge,
                      'Admin Link Array',
                      (_branchData!['adminId'] is List)
                          ? (_branchData!['adminId'] as List).join(', ')
                          : _branchData!['adminId']?.toString(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileRow(IconData icon, String label, String? value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Icon(icon, size: 20, color: _themeAccent),
        const SizedBox(width: 14),
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white70, fontSize: 14),
        ),
        Expanded(
          child: Text(
            value ?? 'Not specified',
            style: const TextStyle(color: Color(0xFFEFEFEF), fontWeight: FontWeight.w400, fontSize: 14, height: 1.3),
          ),
        ),
      ],
    );
  }
}
