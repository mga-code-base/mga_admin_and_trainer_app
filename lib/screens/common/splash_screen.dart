import 'package:flutter/material.dart';
import '../../core/config/app_routes.dart';
import '../../services/api_service.dart';
import '../../services/auth_cache_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final authCacheService = AuthCacheService();
  late final _apiService = ApiService(authCacheService);
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeAppLifecycle();
  }

  Future<void> _initializeAppLifecycle() async {
    setState(() {
      _hasError = false;
      _errorMessage = '';
    });

    await Future.delayed(const Duration(seconds: 3));
    int systemStateCode = await authCacheService.checkPrimaryAdminExistsCode();

    if (!mounted) return;

    if (systemStateCode == 0) {
      Navigator.pushReplacementNamed(context, AppRoutes.primaryAdminSetup);
    } else if (systemStateCode == 1) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    } else {
      setState(() {
        _hasError = true;
        _errorMessage = 'Server connection error. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'MGA',
                  style: TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 4.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ADMINS & TRAINERS LOGIN',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade400,
                    letterSpacing: 4.0,
                  ),
                ),
                const SizedBox(height: 60),
                _hasError
                    ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade400, size: 40),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 15, color: Colors.white70),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade800,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _initializeAppLifecycle,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Retry Connection'),
                    ),
                  ],
                )
                    : const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
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
