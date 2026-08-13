import 'package:flutter/material.dart';
import '../../core/utils/validators.dart';
import '../../models/trainer_model.dart';
import '../../services/api_service.dart';
import '../../services/auth_cache_service.dart';

class DeactivateTrainerScreen extends StatefulWidget {
  const DeactivateTrainerScreen({super.key});

  @override
  State<DeactivateTrainerScreen> createState() =>
      _DeactivateTrainerScreenState();
}

class _DeactivateTrainerScreenState extends State<DeactivateTrainerScreen> {
  final authCacheService = AuthCacheService();
  late final _apiService = ApiService(authCacheService);
  final _searchCtrl = TextEditingController();
  Trainer? _trainer;
  bool _isLoading = false;

  static const Color _themeAccent = Color(0xFFD63031);

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _executeTrainerSearch() async {
    final query = _searchCtrl.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _trainer = null;
    });
    final isNumeric = Validators.isDigitsOnly(query);

    final data = isNumeric
        ? await _apiService.fetchTrainerByIdPath(query)
        : await _apiService.fetchTrainerByUsernamePath(query);

    bool isInvalidTrainer = false;
    if (data != null && data['trainerId'] != null) {
      final String normalizedId = Trainer.normalizeId(data['trainerId']);
      if (normalizedId == '-1') {
        isInvalidTrainer = true;
      }
    }

    if (data == null || isInvalidTrainer) {
      setState(() {
        _isLoading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No active trainer profile records located.'),
          backgroundColor: _themeAccent,
        ),
      );
      return;
    }

    setState(() {
      _trainer = Trainer.fromJson(data);
      _isLoading = false;
    });
  }

  void _deactivateTrainerProfile() async {
    if (_trainer == null) return;
    setState(() => _isLoading = true);

    bool success = await _apiService.deactivateTrainerAccount(_trainer!.trainerId);
    setState(() => _isLoading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Trainer has been suspended successfully.'),
          backgroundColor: Colors.green,
        ),
      );
      _executeTrainerSearch();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to execute deactivation command.'),
          backgroundColor: _themeAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final bool isTrainerCurrentlyActive = _trainer?.isActive ?? true;

    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F0F14),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF16161F),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: _themeAccent,
          ),
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
            borderSide: const BorderSide(color: _themeAccent, width: 1.5),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Suspend Trainer Account'),
          centerTitle: true,
          iconTheme: const IconThemeData(
            color: _themeAccent,
          ),
        ),
        body: SafeArea(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: _themeAccent),
                )
              : Padding(
                  padding: EdgeInsets.all(deviceWidth * 0.05),
                  child: Column(
                    children: [

                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchCtrl,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                              decoration: const InputDecoration(
                                labelText: 'Enter Trainer ID or Username',
                              ),
                              onSubmitted: (_) => _executeTrainerSearch(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            height: 52,
                            width: 52,
                            decoration: BoxDecoration(
                              color: _themeAccent.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              onPressed: _executeTrainerSearch,
                              icon: const Icon(
                                Icons.search,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ],
                      ),

                      if (_trainer != null)
                        Expanded(
                          child: Center(
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,

                                children: [
                                  if (isTrainerCurrentlyActive) ...[
                                    Card(
                                      color: const Color(0xFF1F1315),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        side: BorderSide(
                                          color: _themeAccent.withOpacity(0.3),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: ListTile(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 8,
                                            ),
                                        leading: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: _themeAccent.withOpacity(
                                              0.15,
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.block,
                                            color: _themeAccent,
                                            size: 22,
                                          ),
                                        ),
                                        title: const Text(
                                          'Disable Account Status',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontSize: 14,
                                          ),
                                        ),
                                        trailing: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: _themeAccent,
                                            foregroundColor: Colors.white,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 10,
                                            ),
                                          ),
                                          onPressed: _deactivateTrainerProfile,
                                          child: const Text(
                                            'Disable Now',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                  Card(
                                    color: const Color(0xFF16161F),
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),

                                      side: BorderSide(
                                        color: _themeAccent.withOpacity(0.6),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12.0,
                                        horizontal: 8.0,
                                      ),
                                      child: Column(
                                        children: [
                                          ListTile(
                                            leading: Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: _themeAccent.withOpacity(
                                                  0.12,
                                                ),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.badge,
                                                color: _themeAccent,
                                              ),
                                            ),
                                            title: Text(
                                              _trainer!.name ?? 'Unnamed Profile',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: Colors.white,
                                              ),
                                            ),
                                            subtitle: Padding(
                                              padding: const EdgeInsets.only(
                                                top: 4.0,
                                              ),
                                              child: Text(
                                                'User: ${_trainer!.username ?? 'N/A'}',
                                                style: const TextStyle(
                                                  color: Colors.white38,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                          ),

                                          Divider(
                                            color: _themeAccent,
                                            height: 24,
                                            thickness: 1,
                                            indent: 16,
                                            endIndent: 16,
                                          ),
                                          ListTile(
                                            leading: Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: isTrainerCurrentlyActive
                                                    ? const Color(0x3300E676)
                                                    : const Color(0x33FF5252),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                isTrainerCurrentlyActive
                                                    ? Icons.check_circle_outline
                                                    : Icons.cancel_outlined,
                                                color: isTrainerCurrentlyActive
                                                    ? Colors.greenAccent
                                                    : Colors.redAccent,
                                              ),
                                            ),
                                            title: const Text(
                                              'Account Status Key',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.white70,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            subtitle: Padding(
                                              padding: const EdgeInsets.only(
                                                top: 4.0,
                                              ),
                                              child: Text(
                                                isTrainerCurrentlyActive
                                                    ? 'ACTIVE / OPERATIONAL'
                                                    : 'SUSPENDED / INACTIVE',
                                                style: TextStyle(
                                                  color:
                                                      isTrainerCurrentlyActive
                                                      ? Colors.greenAccent
                                                      : Colors.redAccent,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Divider(
                                            color: _themeAccent.withOpacity(
                                              0.2,
                                            ),
                                            height: 24,
                                            thickness: 1,
                                            indent: 16,
                                            endIndent: 16,
                                          ),
                                          ListTile(
                                            leading: Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: _themeAccent.withOpacity(
                                                  0.12,
                                                ),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.email,
                                                color:
                                                    _themeAccent,
                                              ),
                                            ),
                                            title: const Text(
                                              'Email Address',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.white70,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            subtitle: Padding(
                                              padding: const EdgeInsets.only(
                                                top: 4.0,
                                              ),
                                              child: Text(
                                                _trainer!.emailAddress ?? 'Not Specified',
                                                style: const TextStyle(
                                                  color: Color(0xFFEFEFEF),
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
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
