import 'package:flutter/material.dart';
import '../../models/member_model.dart';
import '../../services/api_service.dart';
import '../../services/auth_cache_service.dart';

class ApproveMembersScreen extends StatefulWidget {
  const ApproveMembersScreen({super.key});

  @override
  State<ApproveMembersScreen> createState() => _ApproveMembersScreenState();
}

class _ApproveMembersScreenState extends State<ApproveMembersScreen> {
  final authCacheService = AuthCacheService();
  late final apiService = ApiService(authCacheService);
  List<Member> _pendingMembersList = [];
  bool _isLoading = true;

  final Color _themeAccent = Colors.orangeAccent.shade200;

  @override
  void initState() {
    super.initState();
    _loadInactiveMembers();
  }

  Future<void> _loadInactiveMembers() async {
    setState(() => _isLoading = true);
    final data = await apiService.fetchInactiveMembers();
    setState(() {
      _pendingMembersList = (data ?? []).map(Member.fromJson).toList();
      _isLoading = false;
    });
  }

  void _promptApprovalForm(String memberId, String name) {
    String selectedUIOption = '28 Days';
    final List<String> durationUIOptions = ['28 Days', '90 Days', '180 Days', '365 Days'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF16161F),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),

            side: BorderSide(color: _themeAccent.withOpacity(0.4)),
          ),
          title: Text('Approve $name', style: const TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Select subscription duration tier:', style: TextStyle(fontSize: 14, color: Colors.white70)),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: selectedUIOption,
                dropdownColor: const Color(0xFF16161F),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF0F0F14),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.white10),
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: _themeAccent, width: 1.5),
                  ),
                ),
                items: durationUIOptions.map((opt) {
                  return DropdownMenuItem(
                    value: opt,
                    child: Text(opt, style: const TextStyle(color: Colors.white, fontSize: 14)),
                  );
                }).toList(),
                onChanged: (v) {
                  if (v != null) selectedUIOption = v;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.white38)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(

                backgroundColor: _themeAccent,
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.pop(context);
                final String numericPayloadValue = selectedUIOption.split(' ').first;
                _executeApprovalPipeline(memberId, name, numericPayloadValue);
              },
              child: const Text('Confirm & Approve', style: TextStyle(fontWeight: FontWeight.bold)),
            )
          ],
        );
      },
    );
  }

  void _executeApprovalPipeline(String memberId, String name, String duration) async {
    setState(() => _isLoading = true);
    bool success = await apiService.approveMemberAccount(memberId, duration);

    if (success) {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF16161F),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: _themeAccent.withOpacity(0.4)),
          ),

          icon: Icon(Icons.face, size: 44, color: _themeAccent),
          title: const Text('Profile Provisioned', style: TextStyle(color: Colors.white)),
          content: const Text(
            'Membership starts once Face Records are saved.',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w400, fontSize: 14, color: Colors.white60),
          ),
          actions: [
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E1E2A),
                  foregroundColor: _themeAccent,
                  side: BorderSide(color: _themeAccent, width: 0.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  _loadInactiveMembers();
                },
                child: const Text('Acknowledge', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      );
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to authorize $name account profile.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _handleDeleteAction(String memberId, String name) async {
    setState(() => _isLoading = true);
    bool success = await apiService.deleteMemberAccount(memberId);
    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$name records removed from registries.'),
          backgroundColor: Colors.green,
        ),
      );
      _loadInactiveMembers();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to delete target record.'),
          backgroundColor: Colors.redAccent,
        ),
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
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF16161F),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _themeAccent),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pending Member Profiles'),
          centerTitle: true,
          iconTheme: IconThemeData(color: _themeAccent),
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator(color: _themeAccent))
            : SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: deviceWidth * 0.05, vertical: deviceHeight * 0.015),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Awaiting Authorizations (${_pendingMembersList.length} profiles)',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: deviceHeight * 0.02),
                Expanded(
                  child: _pendingMembersList.isEmpty
                      ? const Center(
                    child: Text(
                      'No new member sign-up registries require audit.',
                      style: TextStyle(color: Colors.white38, fontSize: 14),
                    ),
                  )
                      : ListView.builder(
                    itemCount: _pendingMembersList.length,
                    itemBuilder: (context, index) {
                      final member = _pendingMembersList[index];
                      final String mId = member.memberId;
                      final String memberName = member.name ?? 'Unknown Member';

                      return Card(
                        color: const Color(0xFF16161F),
                        elevation: 4,
                        margin: EdgeInsets.symmetric(vertical: deviceHeight * 0.01),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: _themeAccent.withOpacity(0.6), width: 1.5),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      memberName,
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: _themeAccent),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _themeAccent.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: _themeAccent.withOpacity(0.4)),
                                    ),
                                    child: Text(
                                      'ID: $mId',
                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _themeAccent),
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text('📱 Phone: ${member.mobileNumber ?? "N/A"}', style: const TextStyle(color: Colors.white60, fontSize: 13)),
                              const SizedBox(height: 4),
                              Text('📧 Email: ${member.emailAddress ?? "N/A"}', style: const TextStyle(color: Colors.white60, fontSize: 13)),
                              const SizedBox(height: 4),
                              Text('📍 Locality Pincode: ${member.localityPincode ?? "N/A"}', style: const TextStyle(color: Colors.white60, fontSize: 13)),
                              Divider(height: 24, color: _themeAccent.withOpacity(0.2), thickness: 1),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF1A1315),
                                      foregroundColor: Colors.redAccent,
                                      elevation: 0,
                                      side: const BorderSide(color: Colors.redAccent),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    ),
                                    onPressed: () => _handleDeleteAction(mId, memberName),
                                    icon: const Icon(Icons.delete_outline, size: 16),
                                    label: const Text('Reject & Delete', style: TextStyle(fontSize: 13)),
                                  ),
                                  const SizedBox(width: 12),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _themeAccent,
                                      foregroundColor: Colors.black,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    ),
                                    onPressed: () => _promptApprovalForm(mId, memberName),
                                    icon: const Icon(Icons.check, size: 16, color: Colors.black),
                                    label: const Text('Approve Entry', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            ],
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
      ),
    );
  }
}
