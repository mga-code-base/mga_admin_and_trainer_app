import 'package:flutter/material.dart';
import '../../core/utils/validators.dart';
import '../../models/member_model.dart';
import '../../services/api_service.dart';
import '../../services/auth_cache_service.dart';

class GetMemberScreen extends StatefulWidget {
  const GetMemberScreen({super.key});

  @override
  State<GetMemberScreen> createState() => _GetMemberScreenState();
}

class _GetMemberScreenState extends State<GetMemberScreen> {
  final authCacheService = AuthCacheService();
  late final _apiService = ApiService(authCacheService);
  final _searchCtrl = TextEditingController();
  Member? _member;
  bool _isLoading = false;

  final Color _themeAccent = Colors.redAccent.shade100;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _executeMemberSearch() async {
    final query = _searchCtrl.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _member = null;
    });

    final isNumeric = Validators.isDigitsOnly(query);
    final data = isNumeric
        ? await _apiService.fetchMemberByIdParam(query)
        : await _apiService.fetchMemberByUsername(query);

    if (data == null || data['memberId'] == -1 || data['memberId'] == '-1') {
      setState(() {
        _isLoading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No active profile records located for input.'),
          backgroundColor: _themeAccent,
        ),
      );
      return;
    }

    setState(() {
      _member = Member.fromJson(data);
      _isLoading = false;
    });
  }

  void _showInlineEditDialog(String targetKey, String labelTitle, String currentValue) {
    final bool isEndDateMode = targetKey == 'membershipEndDate';
    final editCtrl = TextEditingController(text: isEndDateMode ? '' : currentValue);

    showDialog(
        context: context,
        builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF16161F),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),

              side: BorderSide(color: _themeAccent.withOpacity(0.4)),
            ),
            title: Text(
              isEndDateMode ? 'Extend Membership' : 'Modify $labelTitle',
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            content: TextFormField(
              controller: editCtrl,
              keyboardType: isEndDateMode ? TextInputType.number : TextInputType.text,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                labelText: isEndDateMode ? 'Number of Days to Add' : 'Enter new $labelTitle',
                hintText: isEndDateMode ? 'e.g., 30, 90, 365...' : 'Enter value...',
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: const Color(0xFF0F0F14),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.white10)),

                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: _themeAccent, width: 1.5)),
              ),
            ),
            actions: [
            TextButton(
            onPressed: () => Navigator.pop(context),
    child: const Text('Cancel', style: TextStyle(color: Colors.white38)),
    ),
    ElevatedButton(
    style: ElevatedButton.styleFrom(
    backgroundColor: _themeAccent.withOpacity(0.8),
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    elevation: 0,
    ),
    onPressed: () async {
    final String input = editCtrl.text.trim();
    if (input.isEmpty) return;

    Navigator.pop(context);
    setState(() => _isLoading = true);

    final String rawMemberId = _member!.memberId;
    bool success = false;

    if (isEndDateMode) {
    final int? parsedDays = int.tryParse(input);
    if (parsedDays != null) {
    success = await _apiService.updateMembershipEndDate(rawMemberId, parsedDays);
    }
    } else {
    success = await _apiService.updateTrainerForMember(rawMemberId, input);
    }
    if (success) {
      _executeMemberSearch();
    } else {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update member $labelTitle profile fields.'),
          backgroundColor: _themeAccent,
        ),
      );
    }
    },
      child: const Text('Update', style: TextStyle(fontWeight: FontWeight.bold)),
    )
            ],
        ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;

    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F0F14),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF16161F),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _themeAccent),
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
            borderSide: BorderSide(color: _themeAccent, width: 1.5),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Member Directory Lookup'),
          centerTitle: true,
          iconTheme: IconThemeData(color: _themeAccent),
        ),
        body: SafeArea(
          child: _isLoading
              ? Center(child: CircularProgressIndicator(color: _themeAccent))
              : Padding(
            padding: EdgeInsets.all(deviceWidth * 0.05),
            child: Column(
              children: [

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchCtrl,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: const InputDecoration(labelText: 'Enter Member ID or Username'),
                        onSubmitted: (_) => _executeMemberSearch(),
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
                        onPressed: _executeMemberSearch,
                        icon: const Icon(Icons.search, color: Colors.white, size: 24),
                      ),
                    ),
                  ],
                ),

                if (_member != null)
                  Expanded(
                    child: Center(
                      child: Card(
                        color: const Color(0xFF16161F),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: _themeAccent.withOpacity(0.6), width: 1.5),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: _themeAccent.withOpacity(0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.person, color: _themeAccent),
                                ),
                                title: Text(
                                  _member!.name ?? 'Unnamed Profile',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: _themeAccent),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    'ID: ${_member!.memberId}',
                                    style: const TextStyle(color: Colors.white38, fontSize: 13),
                                  ),
                                ),
                              ),
                              Divider(color: _themeAccent, height: 24, thickness: 1, indent: 16, endIndent: 16),
                              ListTile(
                                title: const Text('Membership End Date', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(_member!.membershipEndDate ?? 'N/A', style: const TextStyle(color: Colors.white60)),
                                ),
                                trailing: IconButton(
                                  icon: Icon(Icons.edit_note, color: _themeAccent, size: 24),
                                  onPressed: () => _showInlineEditDialog(
                                    'membershipEndDate',
                                    'End Date',
                                    _member!.membershipEndDate ?? '',
                                  ),
                                ),
                              ),
                              Divider(color: _themeAccent.withOpacity(0.2), height: 24, thickness: 1, indent: 16, endIndent: 16),
                              ListTile(
                                title: const Text('Assigned Trainer ID', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(_member!.trainerAssigned ?? 'Unassigned', style: const TextStyle(color: Colors.white60)),
                                ),
                                trailing: IconButton(
                                  icon: Icon(Icons.edit_note, color: _themeAccent, size: 24),
                                  onPressed: () => _showInlineEditDialog(
                                    'trainerAssigned',
                                    'Trainer ID',
                                    _member!.trainerAssigned ?? '',
                                  ),
                                ),
                              ),
                            ],
                          ),
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
