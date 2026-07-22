import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:t7kem_al7an/features/admin/repository/i_admin_repository.dart';
import '../../../core/constants/firebase_constants.dart';
import '../../authentication/model/user_model.dart';
import '../churches_adding/model/add_church_form_data.dart';
import '../churches_adding/model/church_days.dart';
import '../judges_assigning/model/assign_judge_days.dart';
import '../results/model/church_result_doc.dart';

class AdminRepository implements IAdminRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<String?> sendPushNotification({
    required String title,
    required String body,
  }) async {
    try {
      // Load service account credentials bundled in the app
      final jsonString = await rootBundle
          .loadString('assets/t7kem-al7an-c4a5f-5b9f2aaa218d.json');
      final credentials =
          ServiceAccountCredentials.fromJson(jsonDecode(jsonString));

      const scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

      // Get an OAuth2-authenticated client
      final client = await clientViaServiceAccount(credentials, scopes);

      final projectId = jsonDecode(jsonString)['project_id'];
      final url = Uri.parse(
        'https://fcm.googleapis.com/v1/projects/$projectId/messages:send',
      );

      final message = {
        'message': {
          'topic': 'all_users', // clients must subscribe to this topic
          'data': {
            'title': title,
            'body': body,
          },
        },
      };

      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(message),
      );
      client.close();
      if (response.statusCode == 200) {
        return null;
      }
      return 'Failed to send: ${response.statusCode} ${response.body}';
    } catch (e) {
      return 'Failed to send notification: $e';
    }
  }

  static const Map<String, String> _giftedStageToCollection = {
    'kg': 'kgF',
    'oulaTanya': 'oulaTanyaF',
    'taltaRaba': 'taltaRabaF',
    'khamsaSadsa': 'khamsaSadsaF',
  };

  @override
  Future<String> addChurch(AddChurchFormData data) async {
    final dayId = ChurchDays.toEnglish(data.selectedDayArabic);

    for (final entry in data.categoryToggles.entries) {
      if (entry.value == true) {
        await _addChurchToCollection(entry.key, dayId, data.churchName);
      }
    }

    await _handleDynamicInputs(
        dayId, data.churchName, data.giftedIndividualLists);

    final churchData = {
      ...data.toChurchesDocument(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    final docRef = await _firestore.collection('churches').add(churchData);
    return docRef.id;
  }

  // silent-fail-on-both-paths preserved exactly from original
  Future<void> _addChurchToCollection(
      String collectionName, String dayId, String churchName) async {
    try {
      final docRef = _firestore.collection(collectionName).doc(dayId);
      await docRef.update({
        'churches': FieldValue.arrayUnion([churchName]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      try {
        await _firestore.collection(collectionName).doc(dayId).set({
          'day': dayId,
          'judges': [],
          'churches': [churchName],
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } catch (_) {
        // swallowed, same as original
      }
    }
  }

  Future<void> _handleDynamicInputs(
    String dayId,
    String churchName,
    Map<String, List<String>> giftedIndividualLists,
  ) async {
    for (final stage in _giftedStageToCollection.keys) {
      final names = giftedIndividualLists[stage] ?? [];
      for (final childName in names) {
        await _addChurchToCollection(
          _giftedStageToCollection[stage]!,
          dayId,
          '$churchName - $childName',
        );
      }
    }
  }

  @override
  Stream<QuerySnapshot<UserModel>> watchJudges() {
    return _firestore
        .collection(FirebaseConstants.users)
        .withConverter<UserModel>(
          fromFirestore: (snapshot, _) =>
              UserModel.fromJson(snapshot.data()!, docId: snapshot.id),
          toFirestore: (user, _) => user.toJson(),
        )
        .where(FirebaseConstants.isAdmin, isEqualTo: false)
        .snapshots();
  }

  @override
  Future<String?> addJudge(UserModel user) async {
    try {
      await _firestore.collection(FirebaseConstants.users).add(user.toJson());
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  @override
  Future<String?> editJudge(UserModel user) async {
    try {
      await _firestore
          .collection(FirebaseConstants.users)
          .doc(user.docId)
          .update(user.toJson());
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  @override
  Future<String?> deleteJudge(String docId) async {
    try {
      await _firestore.collection(FirebaseConstants.users).doc(docId).delete();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  @override
  Future<List<String>> fetchJudgeNames() async {
    final snapshot = await _firestore
        .collection('users')
        .where('isAdmin', isEqualTo: false)
        .get();

    final names = <String>[];
    for (final doc in snapshot.docs) {
      final data = doc.data();
      if (data.containsKey('name') && data['name'] != null) {
        names.add(data['name'].toString());
      }
    }
    return names;
  }

  @override
  Future<void> assignJudges({
    required String selectedDayArabic,
    required Map<String, List<String>> judgeMappings,
  }) async {
    final dayId = AssignJudgeDays.toEnglish(selectedDayArabic);

    for (final entry in judgeMappings.entries) {
      if (entry.value.isNotEmpty) {
        await _addJudgesToCollection(entry.key, dayId, entry.value);
      }
    }

    final judgeData = {
      'day': selectedDayArabic,
      'dayId': dayId,
      ...judgeMappings,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    await _firestore.collection('judges').add(judgeData);
  }

  // silent-fail-on-both-paths preserved exactly from original
  Future<void> _addJudgesToCollection(
      String collectionName, String dayId, List<String> judges) async {
    try {
      final docRef = _firestore.collection(collectionName).doc(dayId);
      await docRef.update({
        'judges': FieldValue.arrayUnion(judges),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      try {
        await _firestore.collection(collectionName).doc(dayId).set({
          'day': dayId,
          'judges': judges,
          'churches': [],
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } catch (_) {
        // swallowed, same as original
      }
    }
  }

  @override
  Stream<List<ChurchResultDoc>> watchCollection(String collectionName) {
    return _firestore.collection(collectionName).snapshots().map(
          (snapshot) =>
              snapshot.docs.map(ChurchResultDoc.fromSnapshot).toList(),
        );
  }

  @override
  Future<void> deleteResult(String collectionName, String documentId) {
    return _firestore.collection(collectionName).doc(documentId).delete();
  }
}
