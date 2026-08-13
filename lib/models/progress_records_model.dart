class ProgressRecords {
  final List<MyRecord> chestRecords;
  final List<MyRecord> shoulderRecords;
  final List<MyRecord> backRecords;
  final List<MyRecord> bicepRecords;
  final List<MyRecord> tricepRecords;
  final List<MyRecord> absRecords;
  final List<MyRecord> legsRecords;
  final List<MyRecord> cardioRecords;

  ProgressRecords({
    required this.chestRecords,
    required this.shoulderRecords,
    required this.backRecords,
    required this.bicepRecords,
    required this.tricepRecords,
    required this.absRecords,
    required this.legsRecords,
    required this.cardioRecords,
  });

  factory ProgressRecords.fromJson(Map<String, dynamic> json) {
    return ProgressRecords(
      chestRecords: _parseList(json['chestRecords']),
      shoulderRecords: _parseList(json['shoulderRecords']),
      backRecords: _parseList(json['backRecords']),
      bicepRecords: _parseList(json['bicepRecords']),
      tricepRecords: _parseList(json['tricepRecords']),
      absRecords: _parseList(json['absRecords']),
      legsRecords: _parseList(json['legsRecords'] ?? json['legRecords']),
      cardioRecords: _parseList(json['cardioRecords']),
    );
  }

  static List<MyRecord> _parseList(dynamic list) {
    if (list == null) return [];
    return List<MyRecord>.from(list.map((x) => MyRecord.fromJson(x)));
  }
}

class MyRecord {
  final String memberId;
  final String exerciseName;
  final String targetMuscle;
  final List<ExerciseSet> sets;
  final String date;

  MyRecord({
    required this.memberId,
    required this.exerciseName,
    required this.targetMuscle,
    required this.sets,
    required this.date,
  });

  factory MyRecord.fromJson(Map<String, dynamic> json) {
    var rawSets = json['sets'] as List?;
    return MyRecord(
      memberId: json['memberId'] ?? '',
      exerciseName: json['exerciseName'] ?? 'Unknown Exercise',
      targetMuscle: json['targetMuscle'] ?? 'General',
      date: json['date'] ?? 'N/A',
      sets: rawSets != null
          ? List<ExerciseSet>.from(rawSets.map((x) => ExerciseSet.fromJson(x)))
          : [],
    );
  }
}

class ExerciseSet {
  final double weight;
  final String scaleType;
  final int reps;
  final List<ExerciseSet> subsets;

  ExerciseSet({
    required this.weight,
    required this.scaleType,
    required this.reps,
    required this.subsets,
  });

  factory ExerciseSet.fromJson(Map<String, dynamic> json) {
    var rawSubsets = json['subsets'] as List?;
    return ExerciseSet(
      weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
      scaleType: json['scaleType'] ?? 'kg',
      reps: json['reps'] as int? ?? 0,
      subsets: rawSubsets != null
          ? List<ExerciseSet>.from(rawSubsets.map((x) => ExerciseSet.fromJson(x)))
          : [],
    );
  }
}
