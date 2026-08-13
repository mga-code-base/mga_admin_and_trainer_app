import 'dart:convert';
import '../core/network/api_client.dart';
import '../models/progress_records_model.dart';
import 'auth_cache_service.dart';

class ApiService {
  final AuthCacheService _authCacheService;
  late final ApiClient _client = ApiClient(_authCacheService);

  ApiService(this._authCacheService);

  bool _parseBoolState(dynamic value) {
    if (value == null) return true;
    if (value is bool) return value;
    return value.toString().trim().toLowerCase() == 'true';
  }

  Future<bool> registerAdminMicroservices({
    required Map<String, dynamic> adminData,
    required Map<String, dynamic> branchData,
  }) async {
    try {
      final adminResponse = await _client.post('/admins', body: adminData, auth: false);

      if (adminResponse.statusCode == 200 || adminResponse.statusCode == 201) {
        final trimmedBody = adminResponse.body.trim().toLowerCase();
        if (trimmedBody == 'false') return false;

        final Map<String, dynamic> directBranchBody = Map.from(branchData);
        directBranchBody['adminId'] = (adminData['username'] ?? "").toString();

        final branchResponse = await _client.post('/branch', body: directBranchBody);

        return branchResponse.statusCode == 200 || branchResponse.statusCode == 201;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> fetchInactiveAdmins() async {
    try {
      final response = await _client.get('/admins/inactiveadmins');
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['allAdmins'] != null) {
          return List<Map<String, dynamic>>.from(data['allAdmins']);
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> approveAdminUser(String adminId) async {
    try {
      final response = await _client.put('/admins/updatestatus/$adminId');
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<bool> registerTrainerPayload(Map<String, dynamic> payload) async {
    try {
      final response = await _client.post('/trainers', body: payload, auth: false);
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> fetchInactiveTrainers() async {
    try {
      final String? branchId = await _authCacheService.getCachedBranchId();
      final response = await _client.get('/trainers/allinactive/$branchId');
      if (response.statusCode == 200) {
        final Map<String, dynamic> rawJson = jsonDecode(response.body);
        if (rawJson['allTrainers'] != null) {
          return List<Map<String, dynamic>>.from(rawJson['allTrainers']);
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> approveTrainerAccount(String trainerId) async {
    try {
      final response = await _client.put('/trainers/approve/$trainerId');
      if (response.statusCode == 200) {
        return response.body.trim().toLowerCase() == 'true';
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deactivateTrainerAccount(String trainerId) async {
    try {
      final response = await _client.put('/trainers/disable/$trainerId');
      if (response.statusCode == 200) {
        return response.body.trim().toLowerCase() == 'true';
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteTrainerAccount(String trainerId) async {
    try {
      final response = await _client.delete('/trainers/$trainerId');
      if (response.statusCode == 200) {
        return response.body.trim().toLowerCase() == 'true';
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> fetchTrainerByIdPath(String trainerId) async {
    try {
      final response = await _client.get('/trainers/$trainerId');
      return (response.statusCode == 200 && response.body.trim().isNotEmpty)
          ? jsonDecode(response.body)
          : null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> fetchTrainerByUsernamePath(String username) async {
    try {
      final response = await _client.get('/trainers/username/$username');
      return (response.statusCode == 200 && response.body.trim().isNotEmpty)
          ? jsonDecode(response.body)
          : null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> fetchTrainerProfileDetails(String trainerId) async {
    try {
      final response = await _client.get('/trainers/$trainerId');
      return (response.statusCode == 200 && response.body.trim().isNotEmpty)
          ? jsonDecode(response.body)
          : null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> fetchBranchDetailsByTrainerId(String trainerId) async {
    try {
      final response = await _client.get('/trainers/branchdetails/$trainerId');
      if (response.statusCode == 200 && response.body.trim().isNotEmpty) {
        final Map<String, dynamic> rawJson = jsonDecode(response.body)..remove('equipments');
        return rawJson;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> updateTrainerProfile(String fieldType, String value) async {
    try {
      final response = await _client.post(
        '/trainer/update-profile',
        body: {
          'field': fieldType.toLowerCase().replaceAll(' ', '_'),
          'value': value,
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<List<Map<String, dynamic>>?> fetchInactiveMembers() async {
    try {
      final response = await _client.get('/members/allinactive');
      if (response.statusCode == 200 && response.body.trim().isNotEmpty) {
        final Map<String, dynamic> rawJson = jsonDecode(response.body);
        if (rawJson['allMembers'] != null) {
          return List<Map<String, dynamic>>.from(rawJson['allMembers']);
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> approveMemberAccount(String memberId, String durationValue) async {
    try {
      final response = await _client.put(
        '/members/approve/$memberId',
        query: {'duration': durationValue},
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateMembershipEndDate(String memberId, int durationDays) async {
    try {
      final response = await _client.put(
        '/members/enddate/$memberId',
        query: {'duration': durationDays.toString()},
      );
      if (response.statusCode == 200) {
        return response.body.trim().toLowerCase() == 'true';
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateTrainerForMember(String memberId, String trainerId) async {
    try {
      final response = await _client.put(
        '/members/trainer/$memberId',
        query: {'trainerId': trainerId},
      );
      if (response.statusCode == 200) {
        return response.body.trim().toLowerCase() == 'true';
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteMemberAccount(String memberId) async {
    try {
      final response = await _client.delete('/members/$memberId');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> fetchMemberByIdParam(String numericId) async {
    try {
      final response = await _client.get('/members', query: {'id': numericId});
      return (response.statusCode == 200 && response.body.trim().isNotEmpty)
          ? jsonDecode(response.body)
          : null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> fetchMemberByUsername(String username) async {
    try {
      final response = await _client.get('/members/username/$username');
      return (response.statusCode == 200 && response.body.trim().isNotEmpty)
          ? jsonDecode(response.body)
          : null;
    } catch (e) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> fetchTraineesByTrainerId(String trainerId) async {
    try {
      final response = await _client.get('/members/bytrainerid/$trainerId');
      if (response.statusCode == 200 && response.body.trim().isNotEmpty) {
        final Map<String, dynamic> rawJson = jsonDecode(response.body);
        if (rawJson['allMembers'] != null) {
          return List<Map<String, dynamic>>.from(rawJson['allMembers']);
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchAllBranches() async {
    try {
      final response = await _client.get('/branch/all');
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['allBranches'] != null) {
          return List<Map<String, dynamic>>.from(data['allBranches']);
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> fetchBranchDetails() async {
    try {
      final String adminId = await _authCacheService.getCachedAdminId();
      final response = await _client.get('/branch/getbyadminid/$adminId');
      return response.statusCode == 200 ? jsonDecode(response.body) : {};
    } catch (e) {
      return {};
    }
  }

  Future<List<Map<String, dynamic>>> fetchOnlyEquipmentsByAdminId(String adminId) async {
    try {
      final response = await _client.get('/branch/getbyadminid/$adminId');
      if (response.statusCode == 200 && response.body.trim().isNotEmpty) {
        final Map<String, dynamic> branchJson = jsonDecode(response.body);
        if (branchJson['equipments'] != null) {
          return List<Map<String, dynamic>>.from(branchJson['equipments']);
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>?> addNewEquipmentToBranch(Map<String, dynamic> equipmentItem) async {
    try {
      final String branchId = await _authCacheService.getCachedBranchId();
      final String name = equipmentItem['name'] ?? '';
      final bool working = _parseBoolState(equipmentItem['isInWorkingCondition']);

      final response = await _client.put(
        '/branch/equipments/add/$branchId',
        query: {
          'name': name,
          'isInWorkingCondition': working.toString(),
          'targetMuscle': equipmentItem['targetMuscle'] ?? 'General',
        },
      );

      if (response.statusCode == 200 && response.body.trim().isNotEmpty) {
        final Map<String, dynamic> updatedBranchJson = jsonDecode(response.body);
        if (updatedBranchJson['equipments'] != null) {
          return List<Map<String, dynamic>>.from(updatedBranchJson['equipments']);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> fetchBranchDetailsByAdminId(String adminId) async {
    try {
      final response = await _client.get('/branch/getbyadminid/$adminId');
      if (response.statusCode == 200 && response.body.trim().isNotEmpty) {
        final Map<String, dynamic> rawJson = jsonDecode(response.body)..remove('equipments');
        return rawJson;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> updateExistingEquipment(Map<String, dynamic> updatedItem) async {
    try {
      final String branchId = await _authCacheService.getCachedBranchId();
      final String equipmentId = updatedItem['equipmentId']?.toString() ?? '';
      final String name = updatedItem['name'] ?? '';
      final bool working = _parseBoolState(updatedItem['isInWorkingCondition']);

      if (equipmentId.isEmpty || equipmentId == 'null') return null;

      final response = await _client.put(
        '/branch/equipments/update/$branchId',
        query: {
          'equipmentId': equipmentId,
          'name': name,
          'isInWorkingCondition': working.toString(),
        },
      );

      if (response.statusCode == 200 && response.body.trim().isNotEmpty) {
        final Map<String, dynamic> updatedBranchJson = jsonDecode(response.body);
        if (updatedBranchJson['equipments'] != null) {
          return List<Map<String, dynamic>>.from(updatedBranchJson['equipments']);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> fetchActiveGrievances() async {
    try {
      final response = await _client.get('/grievances/allactive');
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['allGrievances'] != null) {
          return List<Map<String, dynamic>>.from(data['allGrievances']);
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> updateGrievance(String grievanceId, String resolution) async {
    try {
      final response = await _client.put(
        '/grievances',
        body: {
          'grievanceId': grievanceId,
          'resolution': resolution,
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<ProgressRecords?> fetchProgressReport(String memberId) async {
    try {
      final response = await _client.get('/my-records/progress', query: {'memberId': memberId});

      if (response.statusCode == 200 && response.body.trim().isNotEmpty) {
        final Map<String, dynamic> rawJson = jsonDecode(response.body);
        if (rawJson['memberId'] == -1 || rawJson['memberId'] == '-1') return null;
        return ProgressRecords.fromJson(rawJson);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> broadcastNotificationPayload(Map<String, dynamic> notificationBody) async {
    try {
      final response = await _client.post('/messages/send', body: notificationBody);
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteAdminMicroservice(String adminId) async {
    try {
      final response = await _client.delete('/admins/$adminId');
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.body.trim().toLowerCase() == 'true';
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
