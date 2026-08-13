import 'package:flutter/material.dart';
import '../../models/equipment_model.dart';
import '../../services/api_service.dart';
import '../../services/auth_cache_service.dart';

class AddEquipmentScreen extends StatefulWidget {
  const AddEquipmentScreen({super.key});

  @override
  State<AddEquipmentScreen> createState() => _AddEquipmentScreenState();
}

class _AddEquipmentScreenState extends State<AddEquipmentScreen> {
  final authCacheService = AuthCacheService();
  late final apiService = ApiService(authCacheService);
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _submitEquipmentForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final Equipment newEquipment = Equipment(name: _nameCtrl.text.trim());

    final List<Map<String, dynamic>>? updatedList = await apiService.addNewEquipmentToBranch(newEquipment.toJson());
    setState(() => _isSaving = false);

    if (!mounted) return;

    if (updatedList != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Asset logged successfully!'), backgroundColor: Colors.green),
      );
      Navigator.pop(context, updatedList.map(Equipment.fromJson).toList());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update branch inventory.'), backgroundColor: Colors.redAccent),
      );
    }
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
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: const TextStyle(color: Colors.white60, fontSize: 13),
          hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
          filled: true,
          fillColor: const Color(0xFF16161F),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white10),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.purpleAccent, width: 1.5),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(title: const Text('Provision Asset Machine'), centerTitle: true),
        body: _isSaving
            ? const Center(child: CircularProgressIndicator(color: Colors.purpleAccent))
            : SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: deviceWidth * 0.05, vertical: deviceHeight * 0.025),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Add Machine Inventory Details',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  SizedBox(height: deviceHeight * 0.03),
                  TextFormField(
                    controller: _nameCtrl,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: const InputDecoration(
                      labelText: 'Machine Label Name',
                      hintText: 'e.g., Dumbbells, Treadmill, Leg Press...',
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Please define a machine specification label name' : null,
                  ),
                  SizedBox(height: deviceHeight * 0.04),
                  SizedBox(
                    width: double.infinity,
                    height: deviceHeight * 0.055,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purpleAccent.shade700,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      onPressed: _submitEquipmentForm,
                      icon: const Icon(Icons.playlist_add_check),
                      label: const Text(
                        'Commit Machine to Inventory',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
