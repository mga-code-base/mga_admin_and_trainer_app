import 'package:flutter/material.dart';
import '../../models/grievance_model.dart';
import '../../services/api_service.dart';
import '../../services/auth_cache_service.dart';

class ActiveGrievancesScreen extends StatefulWidget {
  const ActiveGrievancesScreen({super.key});

  @override
  State<ActiveGrievancesScreen> createState() => _ActiveGrievancesScreenState();
}

class _ActiveGrievancesScreenState extends State<ActiveGrievancesScreen> {
  final authCacheService = AuthCacheService();
  late final apiService = ApiService(authCacheService);
  Map<String, List<Grievance>> _groupedGrievances = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAndGroupGrievances();
  }

  Future<void> _loadAndGroupGrievances() async {
    setState(() => _isLoading = true);
    final rawList = await apiService.fetchActiveGrievances();
    final List<Grievance> grievances = rawList.map(Grievance.fromJson).toList();

    final Map<String, List<Grievance>> tempGroup = {};
    for (final grievance in grievances) {
      tempGroup.putIfAbsent(grievance.branchId, () => []).add(grievance);
    }

    setState(() {
      _groupedGrievances = tempGroup;
      _isLoading = false;
    });
  }

  void _showResolveDialog(String grievanceId) {
    final resolutionController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => Theme(
        data: ThemeData.dark().copyWith(
          dialogBackgroundColor: const Color(0xFF1E1E1E),
        ),
        child: AlertDialog(
          title: const Text('Resolve Ticket', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Enter final audit or solution details below to resolve this ticket tracking frame.',
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: resolutionController,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Resolution Action',
                  labelStyle: TextStyle(color: Colors.redAccent),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.redAccent)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              onPressed: () async {
                if (resolutionController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Resolution text summary cannot be blank.')),
                  );
                  return;
                }

                final bool success = await apiService.updateGrievance(
                  grievanceId,
                  resolutionController.text.trim(),
                );

                if (!mounted) return;
                Navigator.pop(dialogContext);

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ticket marked as resolved successfully.')),
                  );
                  _loadAndGroupGrievances();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to update ticket. Expectation Failed.')),
                  );
                }
              },
              child: const Text('Submit Resolution'),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<String> branchKeys = _groupedGrievances.keys.toList();

    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        cardTheme: const CardThemeData(
          color: Color(0xFF1E1E1E),
          elevation: 3,
        ),
        dividerColor: Colors.transparent,
      ),
      child: Scaffold(
        appBar: AppBar(title: const Text('Branch Grievance Tracker'), centerTitle: true),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _groupedGrievances.isEmpty
            ? const Center(
          child: Text(
            'No active grievances reported in system logs.',
            style: TextStyle(color: Colors.white54, fontSize: 16),
          ),
        )
            : ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: branchKeys.length,
          itemBuilder: (context, index) {
            final String branchId = branchKeys[index];
            final List<Grievance> tickets = _groupedGrievances[branchId] ?? [];

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ExpansionTile(
                leading: const Icon(Icons.corporate_fare, color: Colors.redAccent, size: 28),
                iconColor: Colors.white70,
                collapsedIconColor: Colors.white54,
                title: Text(
                  'Branch Workspace ID: $branchId',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                subtitle: Text('${tickets.length} Active Tickets Pending', style: const TextStyle(color: Colors.white54)),
                children: tickets.map((ticket) => _buildTicketCard(ticket)).toList(),
              ),
            );
          },
        ),
      ),
    );
  }
  Widget _buildTicketCard(Grievance ticket) {
    final bool isClosed = ticket.isClosed;
    final String targetGrievanceId = ticket.grievanceId;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14.0),
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        border: Border.all(color: Colors.white12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '🎫 $targetGrievanceId',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white70, fontSize: 13),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isClosed ? Colors.greenAccent.withOpacity(0.12) : Colors.orangeAccent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isClosed ? 'RESOLVED' : 'OPEN STATUS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isClosed ? Colors.greenAccent : Colors.orangeAccent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            ticket.issueType,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            '💡 Description:\n${ticket.description}',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 8),
          const Divider(color: Colors.white24),
          const SizedBox(height: 4),
          Text(
            '🔍 Action Taken / Resolution:\n${ticket.resolution}',
            style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: Colors.blueAccent),
          ),
          const SizedBox(height: 12),

          if (!isClosed) ...[
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                    side: BorderSide(color: Colors.red.withOpacity(0.3)),
                  ),
                ),
                icon: const Icon(Icons.edit_note, size: 18),
                label: const Text('Resolve Ticket', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                onPressed: () => _showResolveDialog(targetGrievanceId),
              ),
            ),
            const SizedBox(height: 6),
          ],

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('📅 Filed: ${ticket.date}', style: const TextStyle(fontSize: 11, color: Colors.white38)),
              if (isClosed)
                Text('🏁 Closed: ${ticket.closureDate ?? ''}', style: const TextStyle(fontSize: 11, color: Colors.white38)),
            ],
          ),
        ],
      ),
    );
  }
}
