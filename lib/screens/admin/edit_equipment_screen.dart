import 'package:flutter/material.dart';
import '../../models/equipment_model.dart';
import '../../services/api_service.dart';
import '../../services/auth_cache_service.dart';

class EditEquipmentScreen extends StatefulWidget {
  final Equipment equipment;

  const EditEquipmentScreen({super.key, required this.equipment});

  @override
  State<EditEquipmentScreen> createState() => _EditEquipmentScreenState();
}

class _EditEquipmentScreenState extends State<EditEquipmentScreen> {
  final authCacheService = AuthCacheService();
  late final _apiService = ApiService(authCacheService);
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameCtrl;
  late bool _isInWorkingCondition;
  bool _isSaving = false;
  late String _originalMachineName;

  @override
  void initState() {
    super.initState();
    _originalMachineName = widget.equipment.name;
    _nameCtrl = TextEditingController(text: _originalMachineName);
    _isInWorkingCondition = widget.equipment.isInWorkingCondition;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _submitEditForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final Equipment updatedEquipment = Equipment(
      equipmentId: widget.equipment.equipmentId,
      name: _nameCtrl.text.trim(),
      isInWorkingCondition: _isInWorkingCondition,
      targetMuscle: widget.equipment.targetMuscle,
    );

    final List<Map<String, dynamic>>? updatedList = await _apiService.updateExistingEquipment(updatedEquipment.toJson());
    setState(() => _isSaving = false);

    if (!mounted) return;

    if (updatedList != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Equipment specifications updated!'), backgroundColor: Colors.green),
      );
      Navigator.pop(context, updatedList.map(Equipment.fromJson).toList());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to persist modifications.'), backgroundColor: Colors.redAccent),
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
          filled: true,
          fillColor: const Color(0xFF16161F),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white10),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.amberAccent, width: 1.5),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(title: const Text('Modify Machine Asset'), centerTitle: true),
        body: _isSaving
            ? const Center(child: CircularProgressIndicator(color: Colors.amberAccent))
            : SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: deviceWidth * 0.05, vertical: deviceHeight * 0.025),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Edit Machine Profile Specs', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                  SizedBox(height: deviceHeight * 0.03),
                  TextFormField(
                    controller: _nameCtrl,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: const InputDecoration(labelText: 'Machine Label Name'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Machine label name cannot be blank' : null,
                  ),
                  SizedBox(height: deviceHeight * 0.025),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF16161F),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: SwitchListTile(
                      activeColor: Colors.greenAccent,
                      activeTrackColor: Colors.greenAccent.withAlpha(50),
                      inactiveThumbColor: Colors.redAccent,
                      inactiveTrackColor: Colors.redAccent.withAlpha(50),
                      title: const Text('Operational Condition', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      subtitle: Text(
                        _isInWorkingCondition ? 'Machine is active and working' : 'Machine requires maintenance/repair',
                        style: TextStyle(color: _isInWorkingCondition ? Colors.greenAccent : Colors.redAccent, fontSize: 12),
                      ),
                      value: _isInWorkingCondition,
                      onChanged: (bool value) {
                        setState(() => _isInWorkingCondition = value);
                      },
                    ),
                  ),
                  SizedBox(height: deviceHeight * 0.04),
                  SizedBox(
                    width: double.infinity,
                    height: deviceHeight * 0.055,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amberAccent.shade700,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      onPressed: _submitEditForm,
                      icon: const Icon(Icons.published_with_changes),
                      label: const Text('Save Changes to Catalog', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
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
