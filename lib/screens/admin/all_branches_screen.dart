import 'package:flutter/material.dart';
import '../../models/equipment_model.dart';
import '../../services/api_service.dart';
import '../../services/auth_cache_service.dart';

class AllBranchesScreen extends StatefulWidget {
  const AllBranchesScreen({super.key});

  @override
  State<AllBranchesScreen> createState() => _AllBranchesScreenState();
}

class _AllBranchesScreenState extends State<AllBranchesScreen> {
  final authCacheService = AuthCacheService();
  late final apiService = ApiService(authCacheService);
  List<Map<String, dynamic>> _branchesList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSystemBranchRecords();
  }

  Future<void> _fetchSystemBranchRecords() async {
    setState(() => _isLoading = true);
    final data = await apiService.fetchAllBranches();
    setState(() {
      _branchesList = data;
      _isLoading = false;
    });
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
          elevation: 3,
        ),
        dividerColor: Colors.transparent,
      ),
      child: Scaffold(
        appBar: AppBar(title: const Text('All Registered Branches'), centerTitle: true),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _branchesList.isEmpty
            ? const Center(
          child: Text(
            'No fitness branches found inside system index.',
            style: TextStyle(color: Colors.white54, fontSize: 16),
          ),
        )
            : ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: _branchesList.length,
          itemBuilder: (context, idx) {
            final branch = _branchesList[idx];
            final List<Equipment> equipments = ((branch['equipments'] ?? []) as List)
                .map((e) => Equipment.fromJson(Map<String, dynamic>.from(e)))
                .toList();

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ExpansionTile(
                leading: const Icon(Icons.storefront, color: Colors.blueAccent, size: 28),
                iconColor: Colors.white70,
                collapsedIconColor: Colors.white54,
                title: Text(
                  branch['name'] ?? 'Unnamed Location',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                subtitle: Text(
                  '${branch['city'] ?? ''} - Pincode: ${branch['pincode'] ?? ''}',
                  style: const TextStyle(color: Colors.white70),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(color: Colors.white24),
                        const SizedBox(height: 4),
                        Text(
                          '📍 Full Address: ${branch['address'] ?? 'N/A'}',
                          style: const TextStyle(fontSize: 14, color: Colors.white),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.fitness_center, size: 18, color: Colors.white54),
                            const SizedBox(width: 8),
                            const Text(
                              'Equipment Catalog',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(${equipments.length} items)',
                              style: const TextStyle(fontSize: 15, color: Colors.white54),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        equipments.isEmpty
                            ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            'No assets provisioned to this location yet.',
                            style: TextStyle(fontStyle: FontStyle.italic, color: Colors.white54),
                          ),
                        )
                            : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: equipments.length,
                          itemBuilder: (context, eqIdx) {
                            final eq = equipments[eqIdx];

                            final bool isWorking = eq.isInWorkingCondition;

                            return Card(
                              color: const Color(0xFF2C2C2C),
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              child: ListTile(
                                dense: true,

                                leading: isWorking
                                    ? const Icon(Icons.check_circle_outline, color: Colors.blueAccent, size: 18)
                                    : const Icon(Icons.cancel_outlined, color: Colors.redAccent, size: 18),
                                title: Text(
                                  eq.name.isEmpty ? 'Unknown gear' : eq.name,
                                  style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
                                ),
                                subtitle: Text(
                                  'Muscle Focus: ${eq.targetMuscle ?? 'N/A'}',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
