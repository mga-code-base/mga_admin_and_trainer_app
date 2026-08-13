import 'package:flutter/material.dart';
import '../../core/config/app_routes.dart';
import '../../services/api_service.dart';
import '../../services/auth_cache_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final authCacheService = AuthCacheService();
  late final _apiService = ApiService(authCacheService);

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _hasError = false;
  String _errorMessage = '';

  void _handleLogin(String role) async {
    final String username = _usernameController.text.trim();
    final String password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      _showSnackbar('Please enter both username and password.');
      return;
    }

    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    final response = await authCacheService.loginWithPlainResponse(
      username,
      password,
      role,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (response['httpSuccess'] == true) {
      final bool isPrimaryAdmin = (role == 'Admin' && username.toLowerCase() == 'admin');

      if (!isPrimaryAdmin && response['isActive'] == false) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Invalid Credentials / Account Disabled';
        });
        _showSnackbar(_errorMessage);
        return;
      }

      _showSnackbar(response['message'] ?? 'Welcome back!');
      String nextRoute;

      if (role == 'Admin') {
        if (isPrimaryAdmin) {
          nextRoute = AppRoutes.primaryAdminHome;
        } else {
          nextRoute = AppRoutes.adminHome;
        }
      } else {
        nextRoute = AppRoutes.trainerHome;
      }

      Navigator.pushReplacementNamed(context, nextRoute);
    } else {
      setState(() {
        _hasError = true;
        _errorMessage = 'Invalid Credentials / Account Disabled';
      });
      _showSnackbar(_errorMessage);
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        title: const Text('System Authentication', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 50,
                child: _hasError
                    ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.redAccent, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage,
                        style: const TextStyle(color: Colors.redAccent, fontSize: 14, fontWeight: FontWeight.w500),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                )
                    : const SizedBox.shrink(),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _usernameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Username',
                  labelStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.person, color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade700),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent, width: 2.0),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.lock, color: Colors.grey),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade700),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent, width: 2.0),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              _isLoading
                  ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                ),
              )
                  : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade800,
                        foregroundColor: const Color(0xE6F0F8FF),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                      ),
                      onPressed: () => _handleLogin('Trainer'),
                      child: const Text('Sign In as Trainer', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade800,
                        foregroundColor: const Color(0xE6F0F8FF),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                      ),
                      onPressed: () => _handleLogin('Admin'),
                      child: const Text('Sign In as Admin', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text('Or Join Us', style: TextStyle(color: Colors.grey)),
                      ),
                      Expanded(child: Divider(color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      style: TextButton.styleFrom(foregroundColor: Colors.white70),
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.signupAdmin),
                      icon: const Icon(Icons.admin_panel_settings, size: 20),
                      label: const Text('Sign Up as Admin', style: TextStyle(fontSize: 15)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      style: TextButton.styleFrom(foregroundColor: Colors.white70),
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.signupTrainer),
                      icon: const Icon(Icons.fitness_center, size: 20),
                      label: const Text('Sign Up as Trainer', style: TextStyle(fontSize: 15)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}