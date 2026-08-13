import 'package:flutter/material.dart';
import '../../core/config/app_routes.dart';
import '../../models/equipment_model.dart';
import '../../services/api_service.dart';
import '../../services/auth_cache_service.dart';
import 'edit_equipment_screen.dart';

class BranchEquipmentsScreen extends StatefulWidget {
  const BranchEquipmentsScreen({super.key});

  @override
  State<BranchEquipmentsScreen> createState() => _BranchEquipmentsScreenState();
}

class _BranchEquipmentsScreenState extends State<BranchEquipmentsScreen> {
  final authCacheService = AuthCacheService();
  late final _apiService = ApiService(authCacheService);
  List<Equipment> _equipmentsList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOnlyEquipmentsCatalog();
  }

  Future<void> _loadOnlyEquipmentsCatalog() async {
    setState(() => _isLoading = true);
    final String activeAdminId = await authCacheService.getCachedAdminId();
    final data = await _apiService.fetchOnlyEquipmentsByAdminId(activeAdminId);

    setState(() {
      _equipmentsList = data.map(Equipment.fromJson).toList();
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
              title: const Text('Branch Equipment Catalog'),
              centerTitle: true,
            ),
            body: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.purpleAccent))
                : SafeArea(
                child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: deviceWidth * 0.05, vertical: deviceHeight * 0.015),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(
                    'Provisioned Assets (${_equipmentsList.length} items)',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    SizedBox(height: deviceHeight * 0.02),
                    Expanded(
                        child: _equipmentsList.isEmpty
                            ? const Center(
                          child: Text(
                            'No fitness equipment provisioned to this branch yet.',
                            style: TextStyle(color: Colors.white38, fontSize: 14),
                          ),
                        )
                            : ListView.builder(
                            itemCount: _equipmentsList.length,
                            itemBuilder: (context, index) {
                              final gear = _equipmentsList[index];
                              final bool working = gear.isInWorkingCondition;

                              return Card(
                                  color: const Color(0xFF16161F),
                                  elevation: 0,
                                  margin: EdgeInsets.symmetric(vertical: deviceHeight * 0.008),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    side: const BorderSide(color: Colors.white10, width: 1),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                    leading: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.purpleAccent.withAlpha(20),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.fitness_center, color: Colors.purpleAccent, size: 22),
                                    ),
                                    title: Text(
                                      gear.name.isEmpty ? 'Unknown Machine' : gear.name,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Row(
                                        children: [
                                          Icon(
                                            working ? Icons.check_circle_outline : Icons.error_outline,
                                            size: 14,
                                            color: working ? Colors.greenAccent : Colors.redAccent,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            working ? 'Operational' : 'Under Maintenance',
                                            style: TextStyle(
                                              color: working ? Colors.greenAccent : Colors.redAccent,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.edit_note, color: Colors.amberAccent, size: 24),
                                      onPressed: () async {
                                        final dynamic updatedCatalogResult = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => EditEquipmentScreen(equipment: gear),
                                          ),
                                        );
                                        if (updatedCatalogResult != null && updatedCatalogResult is List<Equipment>) {
                                          setState(() {
                                            _equipmentsList = updatedCatalogResult;
                                          });
                                        } else if (updatedCatalogResult == true) {
                                          _loadOnlyEquipmentsCatalog();
                                        }
                                      },
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
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: Colors.purpleAccent.shade700,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            icon: const Icon(Icons.add, size: 20),
            label: const Text('Add Equipment', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            onPressed: () async {
              final dynamic updatedCatalogResult = await Navigator.pushNamed(context, AppRoutes.addEquipment);

              if (updatedCatalogResult != null && updatedCatalogResult is List<Equipment>) {
                setState(() {
                  _equipmentsList = updatedCatalogResult;
                });
              } else if (updatedCatalogResult == true) {
                _loadOnlyEquipmentsCatalog();
              }
            },
          ),
        ),
    );
  }
}
