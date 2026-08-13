import 'package:flutter/material.dart';
import '../../core/config/app_routes.dart';
import '../../core/utils/validators.dart';
import '../../services/api_service.dart';
import '../../services/auth_cache_service.dart';

class PrimaryAdminSetupScreen extends StatefulWidget {
  const PrimaryAdminSetupScreen({super.key});

  @override
  State<PrimaryAdminSetupScreen> createState() => _PrimaryAdminSetupScreenState();
}

class _PrimaryAdminSetupScreenState extends State<PrimaryAdminSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final authCacheService = AuthCacheService();
  late final _apiService = ApiService(authCacheService);
  bool _isLoading = false;
  bool _obscurePassword = true;

  void _submitPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final Map<String, dynamic> result = await authCacheService.setupAdminPassword(_passwordController.text);
      setState(() => _isLoading = false);

      if (!mounted) return;

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Admin password setup successful!')),
        );
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Setup failed. Please try again.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey.shade900,
        appBar: AppBar(
          title: const Text('Setup Primary Admin', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          centerTitle: true,
        ),
        body: Center(
            child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    const Text(
                    'Default Admin Username: admin',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: const TextStyle(color: Colors.grey),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade700)),
                      focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.blueAccent, width: 2.0)),
                      errorBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.redAccent)),
                      focusedErrorBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.redAccent, width: 2.0)),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please enter a password';
                      if (!Validators.isStrongPassword(value)) return 'Password criteria not met';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Min 8 characters, must include letters, numbers & symbols.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                    softWrap: true,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 32),
                      _isLoading
                          ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                        ),
                      )
                          : SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade800,
                            foregroundColor: const Color(0xE6F0F8FF),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                            elevation: 2,
                          ),
                          onPressed: _submitPassword,
                          child: const Text(
                            'Create Admin',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ),
        ),
    );
  }
}
