import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/auth_cache_service.dart';
import '../../models/progress_records_model.dart';

class TraineeProgressScreen extends StatefulWidget {
  const TraineeProgressScreen({super.key});

  @override
  State<TraineeProgressScreen> createState() => _TraineeProgressScreenState();
}

class _MyRecordCard extends StatelessWidget {
  final MyRecord record;
  const _MyRecordCard({required this.record});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF16161F),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Colors.white10),
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
                    record.exerciseName,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                Text(
                  record.date,
                  style: const TextStyle(fontSize: 12, color: Colors.white38),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Target Muscle: ${record.targetMuscle}',
              style: const TextStyle(fontSize: 12, color: Colors.cyanAccent),
            ),
            const Divider(color: Colors.white10, height: 20),
            ...record.sets.asMap().entries.map((entry) {
              int index = entry.key;
              ExerciseSet set = entry.value;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Row(
                  children: [
                    Text(
                      'Set ${index + 1}: ',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white60),
                    ),
                    Text(
                      '${set.weight} ${set.scaleType} × ${set.reps} reps',
                      style: const TextStyle(fontSize: 13, color: Color(0xFFEFEFEF)),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _TraineeProgressScreenState extends State<TraineeProgressScreen> {
  final authCacheService = AuthCacheService();
  late final _apiService = ApiService(authCacheService);
  final _searchCtrl = TextEditingController();

  ProgressRecords? _allRecords;
  List<MyRecord> _filteredDisplayList = [];
  bool _isLoading = false;

  String _selectedCategory = 'Chest';
  final List<String> _categories = ['Chest', 'Shoulder', 'Back', 'Bicep', 'Tricep', 'Legs', 'Abs', 'Cardio'];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _searchTraineeRecords() async {
    final query = _searchCtrl.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _allRecords = null;
      _filteredDisplayList = [];
    });
    final ProgressRecords? data = await _apiService.fetchProgressReport(query);

    setState(() {
      _isLoading = false;
    });

    if (data == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No report records found for this member ID.'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    _allRecords = data;
    _applyCategoryFilter();
  }
  void _applyCategoryFilter() {
    if (_allRecords == null) return;

    setState(() {
      switch (_selectedCategory) {
        case 'Chest': _filteredDisplayList = _allRecords!.chestRecords; break;
        case 'Shoulder': _filteredDisplayList = _allRecords!.shoulderRecords; break;
        case 'Back': _filteredDisplayList = _allRecords!.backRecords; break;
        case 'Bicep': _filteredDisplayList = _allRecords!.bicepRecords; break;
        case 'Tricep': _filteredDisplayList = _allRecords!.tricepRecords; break;
        case 'Legs': _filteredDisplayList = _allRecords!.legsRecords; break;
        case 'Abs': _filteredDisplayList = _allRecords!.absRecords; break;
        case 'Cardio': _filteredDisplayList = _allRecords!.cardioRecords; break;
        default: _filteredDisplayList = [];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;

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
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white10)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.purpleAccent, width: 1.5)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(title: const Text('Progress Tracking Logs'), centerTitle: true),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(deviceWidth * 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchCtrl,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: const InputDecoration(labelText: 'Enter Trainee Member ID'),
                        onSubmitted: (_) => _searchTraineeRecords(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      height: 52, width: 52,
                      decoration: BoxDecoration(color: Colors.purpleAccent.shade700, borderRadius: BorderRadius.circular(12)),
                      child: IconButton(
                        onPressed: _searchTraineeRecords,
                        icon: const Icon(Icons.analytics_outlined, color: Colors.white, size: 24),
                      ),
                    ),
                  ],
                ),
                if (_allRecords != null) ...[
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filter Muscle Group:',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white70),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          dropdownColor: const Color(0xFF16161F),
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.white10)),
                          ),
                          items: _categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              _selectedCategory = val;
                              _applyCategoryFilter();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _filteredDisplayList.isEmpty
                        ? Center(
                      child: Text(
                        'No performance entries saved for $_selectedCategory focus.',
                        style: const TextStyle(color: Colors.white38, fontSize: 14),
                      ),
                    )
                        : ListView.builder(
                      itemCount: _filteredDisplayList.length,
                      itemBuilder: (context, index) => _MyRecordCard(record: _filteredDisplayList[index]),
                    ),
                  ),
                ],
                if (_isLoading)
                  const Expanded(child: Center(child: CircularProgressIndicator(color: Colors.purpleAccent))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
