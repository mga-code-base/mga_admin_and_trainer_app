import 'package:flutter/material.dart';
import '../../core/utils/validators.dart';
import '../../models/equipment_model.dart';
import '../../services/api_service.dart';
import '../../services/auth_cache_service.dart';
import '../../widgets/keep_alive_wrapper.dart';

class SignupAdminTabsScreen extends StatefulWidget {
  const SignupAdminTabsScreen({super.key});

  @override
  State<SignupAdminTabsScreen> createState() => _SignupAdminTabsScreenState();
}

class _SignupAdminTabsScreenState extends State<SignupAdminTabsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final authCacheService = AuthCacheService();
  late final _apiService = ApiService(authCacheService);
  bool _isLoading = false;
  bool _isPasswordObscured = true;

  final _adminFormKey = GlobalKey<FormState>();
  final _branchFormKey = GlobalKey<FormState>();
  final _equipmentFormKey = GlobalKey<FormState>();

  final ScrollController _adminScrollCtrl = ScrollController();
  final ScrollController _branchScrollCtrl = ScrollController();

  final _nameFocusNode = FocusNode();
  final _userFocusNode = FocusNode();
  final _passFocusNode = FocusNode();
  final _mobileFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();

  final _branchNameFocusNode = FocusNode();
  final _pincodeFocusNode = FocusNode();
  final _addressFocusNode = FocusNode();
  final _cityFocusNode = FocusNode();

  final _nameCtrl = TextEditingController();
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  final _branchNameCtrl = TextEditingController();
  final _pincodeCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();

  final List<Equipment> _addedEquipments = [];
  final _eqNameCtrl = TextEditingController();

  String? _selectedMuscleGroup;
  final List<String> _muscleGroups = [
    'chest', 'shoulder', 'back', 'biceps', 'triceps', 'abs', 'legs', 'cardio', 'multiple',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  void _addEquipmentToList() {
    if (_equipmentFormKey.currentState?.validate() ?? false) {
      final String enteredName = _eqNameCtrl.text.trim();

      if (enteredName.isNotEmpty && _selectedMuscleGroup != null) {
        final bool isDuplicate = _addedEquipments.any(
              (eq) => eq.name.toLowerCase() == enteredName.toLowerCase(),
        );

        if (isDuplicate) {
          _showErrorToast('"$enteredName" is already in your equipment list!');
          return;
        }

        setState(() {
          _addedEquipments.add(Equipment(
            name: enteredName,
            targetMuscle: _selectedMuscleGroup!.toLowerCase(),
          ));

          _eqNameCtrl.clear();
          _selectedMuscleGroup = null;
          _equipmentFormKey.currentState?.reset();
        });
      }
    }
  }

  void _autoAddBasicEquipments() {
    final List<Equipment> basicEquipments = [
      const Equipment(name: "Treadmill", targetMuscle: "cardio"),
      const Equipment(name: "Flat Bench Press", targetMuscle: "chest"),
      const Equipment(name: "Incline Dumbbell Bench", targetMuscle: "chest"),
      const Equipment(name: "Lat Pulldown Machine", targetMuscle: "back"),
      const Equipment(name: "Seated Cable Row", targetMuscle: "back"),
      const Equipment(name: "Shoulder Overhead Press", targetMuscle: "shoulder"),
      const Equipment(name: "EZ Bar Bicep Curl", targetMuscle: "biceps"),
      const Equipment(name: "Tricep Pushdown Cable", targetMuscle: "triceps"),
      const Equipment(name: "Leg Press Machine", targetMuscle: "legs"),
      const Equipment(name: "Squat Rack", targetMuscle: "legs"),
    ];

    setState(() {
      for (var item in basicEquipments) {
        final bool isDuplicate = _addedEquipments.any(
              (eq) => eq.name.toLowerCase() == item.name.toLowerCase(),
        );
        if (!isDuplicate) {
          _addedEquipments.add(item);
        }
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Basic equipments auto-added to the list!')),
    );
  }

  void _scrollToAndFocus(FocusNode focusNode, ScrollController scrollCtrl) {
    focusNode.requestFocus();
    if (focusNode.context != null) {
      Scrollable.ensureVisible(
        focusNode.context!,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _submitWholePayload() async {

    if (!(_adminFormKey.currentState?.validate() ?? false)) {
      _showErrorToast('Please correct missing or invalid fields in Admin Details.');
      _tabController.animateTo(0);

      if (_nameCtrl.text.trim().isEmpty || !Validators.isAlphanumericWithSpaces(_nameCtrl.text)) {
        _scrollToAndFocus(_nameFocusNode, _adminScrollCtrl);
      } else if (_userCtrl.text.trim().isEmpty) {
        _scrollToAndFocus(_userFocusNode, _adminScrollCtrl);
      } else if (_passCtrl.text.length < 6) {
        _scrollToAndFocus(_passFocusNode, _adminScrollCtrl);
      } else if (!Validators.isMobileNumber(_mobileCtrl.text)) {
        _scrollToAndFocus(_mobileFocusNode, _adminScrollCtrl);
      } else if (!Validators.isValidEmail(_emailCtrl.text)) {
        _scrollToAndFocus(_emailFocusNode, _adminScrollCtrl);
      }
      return;
    }

    if (!(_branchFormKey.currentState?.validate() ?? false)) {
      _showErrorToast('Please correct missing or invalid fields in Branch Setup.');
      _tabController.animateTo(1);

      if (_branchNameCtrl.text.trim().isEmpty) {
        _scrollToAndFocus(_branchNameFocusNode, _branchScrollCtrl);
      } else if (!Validators.isPincode(_pincodeCtrl.text)) {
        _scrollToAndFocus(_pincodeFocusNode, _branchScrollCtrl);
      } else if (_addressCtrl.text.trim().isEmpty) {
        _scrollToAndFocus(_addressFocusNode, _branchScrollCtrl);
      } else if (_cityCtrl.text.trim().isEmpty) {
        _scrollToAndFocus(_cityFocusNode, _branchScrollCtrl);
      }
      return;
    }

    if (_addedEquipments.length < 10) {
      final int missingCount = 10 - _addedEquipments.length;
      _showErrorToast('Please add at least 10 equipments. Add $missingCount more item(s).');
      _tabController.animateTo(2);
      return;
    }

    final Map<String, dynamic> flatAdminPayload = {
      "name": _nameCtrl.text.trim(),
      "username": _userCtrl.text.trim(),
      "password": _passCtrl.text,
      "mobileNumber": _mobileCtrl.text.trim(),
      "emailAddress": _emailCtrl.text.trim(),
    };

    final Map<String, dynamic> flatBranchPayload = {
      "name": _branchNameCtrl.text.trim(),
      "pincode": int.tryParse(_pincodeCtrl.text.trim()) ?? 0,
      "address": _addressCtrl.text.trim(),
      "city": _cityCtrl.text.trim(),
      "equipments": _addedEquipments.map((e) => e.toJson()).toList(),
    };

    setState(() => _isLoading = true);

    bool success = await _apiService.registerAdminMicroservices(
      adminData: flatAdminPayload,
      branchData: flatBranchPayload,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Registration done! Please wait for Super Admin\'s Approval'
              : 'Submission failed.',
        ),
      ),
    );

    if (success) Navigator.pop(context);
  }

  void _showErrorToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _adminScrollCtrl.dispose();
    _branchScrollCtrl.dispose();

    _nameFocusNode.dispose();
    _userFocusNode.dispose();
    _passFocusNode.dispose();
    _mobileFocusNode.dispose();
    _emailFocusNode.dispose();

    _branchNameFocusNode.dispose();
    _pincodeFocusNode.dispose();
    _addressFocusNode.dispose();
    _cityFocusNode.dispose();

    _nameCtrl.dispose();
    _userCtrl.dispose();
    _passCtrl.dispose();
    _mobileCtrl.dispose();
    _emailCtrl.dispose();
    _branchNameCtrl.dispose();
    _pincodeCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _eqNameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          elevation: 0,
        ),
        cardTheme: const CardThemeData(color: Color(0xFF1E1E1E)),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin & Branch Setup Wizard'),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.amber,
            labelColor: Colors.amber,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(icon: Icon(Icons.person), text: 'Details'),
              Tab(icon: Icon(Icons.store), text: 'Branch'),
              Tab(icon: Icon(Icons.fitness_center), text: 'Equipments'),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.amber))
            : TabBarView(
          controller: _tabController,
          children: [
            KeepAliveWrapper(child: _buildDetailsForm()),
            KeepAliveWrapper(child: _buildBranchForm()),
            KeepAliveWrapper(child: _buildEquipmentForm()),
          ],
        ),
        bottomNavigationBar: _isLoading
            ? null
            : Container(
          padding: const EdgeInsets.all(12),
          color: const Color(0xFF1E1E1E),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
              minimumSize: const Size.fromHeight(50),
            ),
            onPressed: _submitWholePayload,
            icon: const Icon(Icons.cloud_upload),
            label: const Text(
              'Submit',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsForm() {
    return Form(
      key: _adminFormKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: ListView(
        controller: _adminScrollCtrl,
        padding: const EdgeInsets.all(16),
        children: [
          TextFormField(
            controller: _nameCtrl,
            focusNode: _nameFocusNode,
            decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()),
            validator: (val) {
              if (val == null || val.trim().isEmpty) return 'Please enter full admin name';
              if (!Validators.isAlphanumericWithSpaces(val)) {
                return 'Only letters and numbers are allowed (no special characters)';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),

          TextFormField(
            controller: _userCtrl,
            focusNode: _userFocusNode,
            textCapitalization: TextCapitalization.none,
            autocorrect: false,
            decoration: const InputDecoration(labelText: 'Username', border: OutlineInputBorder()),
            validator: (val) => val == null || val.trim().isEmpty ? 'Username field cannot be blank' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _passCtrl,
            focusNode: _passFocusNode,
            obscureText: _isPasswordObscured,
            decoration: InputDecoration(
              labelText: 'Password',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(_isPasswordObscured ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                onPressed: () => setState(() => _isPasswordObscured = !_isPasswordObscured),
              ),
            ),
            validator: (val) => val == null || val.length < 6 ? 'Password security threshold must be >= 6 chars' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _mobileCtrl,
            focusNode: _mobileFocusNode,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: 'Mobile Number', border: OutlineInputBorder()),
            validator: (val) {
              if (val == null || val.trim().isEmpty) return 'Mobile number tracker is required';
              if (!Validators.isMobileNumber(val)) {
                return 'Mobile number must be exactly 10 digits long';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _emailCtrl,
            focusNode: _emailFocusNode,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Email Address', border: OutlineInputBorder()),
            validator: (val) {
              if (val == null || val.trim().isEmpty) return 'Email link path is required';
              if (!Validators.isValidEmail(val)) {
                return 'Provide a valid email address (e.g., name@domain.com)';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBranchForm() {
    return Form(
      key: _branchFormKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: ListView(
        controller: _branchScrollCtrl,
        padding: const EdgeInsets.all(16),
        children: [
          TextFormField(
            controller: _branchNameCtrl,
            focusNode: _branchNameFocusNode,
            decoration: const InputDecoration(labelText: 'Branch Center Name', border: OutlineInputBorder()),
            validator: (val) => val == null || val.trim().isEmpty ? 'Branch business name required' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _pincodeCtrl,
            focusNode: _pincodeFocusNode,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Area Pincode', border: OutlineInputBorder()),
            validator: (val) {
              if (val == null || val.trim().isEmpty) return 'Please supply an area code sequence';
              if (!Validators.isPincode(val)) {
                return 'Area Pincode must be exactly 6 digits long';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _addressCtrl,
            focusNode: _addressFocusNode,
            decoration: const InputDecoration(labelText: 'Suite / Street Address', border: OutlineInputBorder()),
            validator: (val) => val == null || val.trim().isEmpty ? 'Physical suite/street layout required' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _cityCtrl,
            focusNode: _cityFocusNode,
            decoration: const InputDecoration(labelText: 'City Location', border: OutlineInputBorder()),
            validator: (val) => val == null || val.trim().isEmpty ? 'Target city parameter required' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildEquipmentForm() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Form(
                key: _equipmentFormKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _eqNameCtrl,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Equipment Model Name',
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) => val == null || val.trim().isEmpty ? 'Equipment name is required' : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedMuscleGroup,
                      hint: const Text('Select Target Muscle Group'),
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                        border: OutlineInputBorder(),
                      ),
                      dropdownColor: const Color(0xFF1E1E1E),
                      items: _muscleGroups.map((String muscle) {
                        return DropdownMenuItem<String>(value: muscle, child: Text(muscle));
                      }).toList(),
                      onChanged: (newValue) => setState(() => _selectedMuscleGroup = newValue),
                      validator: (val) => val == null ? 'Please select a targeted muscle group' : null,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black,
                        minimumSize: const Size.fromHeight(45),
                      ),
                      onPressed: _addEquipmentToList,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Equipment item to List', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 8),

                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.amber,
                        side: const BorderSide(color: Colors.amber),
                        minimumSize: const Size.fromHeight(40),
                      ),
                      onPressed: _autoAddBasicEquipments,
                      icon: const Icon(Icons.flash_on),
                      label: const Text('Auto Add Basic Equipments'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const Divider(),
        Expanded(
          child: _addedEquipments.isEmpty
              ? const Center(child: Text('No equipment items tracked yet (Minimum 10 required).', style: TextStyle(color: Colors.grey)))
              : Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Equipments: ${_addedEquipments.length}',
                  style: TextStyle(
                    color: _addedEquipments.length < 10 ? Colors.orangeAccent : Colors.greenAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _addedEquipments.length,
                  itemBuilder: (context, idx) {
                    final eq = _addedEquipments[idx];
                    return ListTile(
                      leading: const Icon(Icons.check_circle_outline, color: Colors.amber),
                      title: Text(eq.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      subtitle: Text("Target Muscle: ${eq.targetMuscle}", style: const TextStyle(color: Colors.grey)),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        onPressed: () => setState(() => _addedEquipments.removeAt(idx)),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
