import 'dart:convert';
import 'package:flutter/material.dart';
import '../../core/utils/validators.dart';
import '../../services/api_service.dart';
import '../../services/auth_cache_service.dart';

class SignupTrainerScreen extends StatefulWidget {
  const SignupTrainerScreen({super.key});

  @override
  State<SignupTrainerScreen> createState() => _SignupTrainerScreenState();
}

class _SignupTrainerScreenState extends State<SignupTrainerScreen> {
  final authCacheService = AuthCacheService();
  late final _apiService = ApiService(authCacheService);

  bool _isLoading = false;
  bool _isBranchesLoading = true;
  bool _isPasswordObscured = true;

  final _nameCtrl = TextEditingController();
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  String? _selectedBranchId;
  List<Map<String, dynamic>> _branchesList = [];

  @override
  void initState() {
    super.initState();
    _fetchDropdownBranches();
  }

  Future<void> _fetchDropdownBranches() async {
    try {
      final List<Map<String, dynamic>> data = await _apiService
          .fetchAllBranches();
      setState(() {
        _branchesList = data;
        _isBranchesLoading = false;
      });
    } catch (e) {
      setState(() => _isBranchesLoading = false);
      _showErrorToast('Failed to retrieve system branch records.');
    }
  }

  void _showErrorToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _userCtrl.dispose();
    _passCtrl.dispose();
    _mobileCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  void _submitTrainer() async {
    final cleanName = _nameCtrl.text.trim();
    final cleanUser = _userCtrl.text.trim();
    final cleanPass = _passCtrl.text;
    final cleanMobile = _mobileCtrl.text.trim();
    final cleanEmail = _emailCtrl.text.trim();

    if (cleanName.isEmpty || !Validators.isLettersWithSpaces(cleanName)) {
      _showErrorToast('Full Name must contain only letters and spaces.');
      return;
    }
    if (cleanUser.isEmpty) {
      _showErrorToast('Username cannot be empty.');
      return;
    }
    if (cleanPass.length < 6) {
      _showErrorToast('Password must be at least 6 characters.');
      return;
    }
    if (!Validators.isMobileNumber(cleanMobile)) {
      _showErrorToast('Mobile number must be exactly 10 digits long.');
      return;
    }
    if (!Validators.isValidEmail(cleanEmail)) {
      _showErrorToast('Provide a valid email address with a domain extension.');
      return;
    }
    if (_selectedBranchId == null) {
      _showErrorToast('Please select a target home Branch for this trainer.');
      return;
    }

    final Map<String, dynamic> trainerPayload = {
      "name": cleanName,
      "username": cleanUser,
      "password": cleanPass,
      "mobileNumber": cleanMobile,
      "emailAddress": cleanEmail,
      "branchId": _selectedBranchId,
    };

    setState(() => _isLoading = true);
    bool success = await _apiService.registerTrainerPayload(trainerPayload);
    setState(() => _isLoading = false);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Trainer registration successful!' : 'Submission failure.',
        ),
        backgroundColor: success ? Colors.green : Colors.redAccent,
      ),
    );
    if (success) Navigator.pop(context);
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
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(title: const Text('Trainer Sign Up Profile')),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.amber),
              )
            : Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: _buildFormFields(),
                ),
              ),
      ),
    );
  }

  Widget _buildFormFields() {
    return ListView(
      children: [
        const Text(
          'Create Trainer Profile Account',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.amber,
          ),
        ),
        const SizedBox(height: 25),
        TextFormField(
          controller: _nameCtrl,
          decoration: const InputDecoration(
            labelText: 'Full Name',
            border: OutlineInputBorder(),
          ),
          validator: (val) {
            if (val == null || val.trim().isEmpty)
              return 'Please enter full trainer name';
            if (!Validators.isLettersWithSpaces(val)) {
              return 'Only letters are allowed (no special characters)';
            }
            return null;
          },
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _userCtrl,
          decoration: const InputDecoration(
            labelText: 'Username',
            border: OutlineInputBorder(),
          ),
          validator: (val) => val == null || val.trim().isEmpty
              ? 'Username field cannot be blank'
              : null,
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _passCtrl,
          obscureText: _isPasswordObscured,
          decoration: InputDecoration(
            labelText: 'Password',
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordObscured ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey,
              ),
              onPressed: () =>
                  setState(() => _isPasswordObscured = !_isPasswordObscured),
            ),
          ),
          validator: (val) => val == null || val.length < 6
              ? 'Password security threshold must be >= 6 chars'
              : null,
        ),
        const SizedBox(height: 14),
        _isBranchesLoading
            ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Center(
                  child: LinearProgressIndicator(color: Colors.amber),
                ),
              )
            : DropdownButtonFormField<String>(
                value: _selectedBranchId,
                hint: const Text('Select Home Branch'),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Branch',
                ),
                dropdownColor: const Color(0xFF1E1E1E),
                items: _branchesList.map((branch) {
                  final String id = (branch['branchId'] ?? branch['id'] ?? '')
                      .toString();
                  final String name = branch['name'] ?? 'Unnamed Branch';

                  return DropdownMenuItem<String>(
                    value: id,
                    child: Text(
                      '$id - $name',
                      style: const TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  );
                }).toList(),
                onChanged: (newValue) =>
                    setState(() => _selectedBranchId = newValue),
                validator: (val) => val == null
                    ? 'Please map this profile to an active branch'
                    : null,
              ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _mobileCtrl,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Mobile Number',
            border: OutlineInputBorder(),
          ),
          validator: (val) {
            if (val == null || val.trim().isEmpty)
              return 'Mobile number tracker is required';
            if (!Validators.isMobileNumber(val))
              return 'Mobile number must be exactly 10 digits long';
            return null;
          },
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Email Address',
            border: OutlineInputBorder(),
          ),
          validator: (val) {
            if (val == null || val.trim().isEmpty)
              return 'Email link path is required';
            if (!Validators.isValidEmail(val))
              return 'Provide a valid email address (e.g., name@domain.com)';
            return null;
          },
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: _submitTrainer,
          child: const Text(
            'Save Profile Records',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
