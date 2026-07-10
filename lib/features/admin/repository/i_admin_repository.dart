import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:t7kem_al7an/features/authentication/model/user_model.dart';
import '../churches_adding/model/add_church_form_data.dart';
import '../results/model/church_result_doc.dart';

abstract interface class IAdminRepository {
  Future<String?> sendPushNotification({
    required String title,
    required String body,
  });

  Future<String?> addJudge(UserModel user);

  Future<String?> editJudge(UserModel user);

  Future<String?> deleteJudge(String docId);

  Future<String> addChurch(AddChurchFormData data);

  Future<void> assignJudges({
    required String selectedDayArabic,
    required Map<String, List<String>> judgeMappings,
  });

  Future<List<String>> fetchJudgeNames();

  Stream<QuerySnapshot<UserModel>> watchJudges();

  Stream<List<ChurchResultDoc>> watchCollection(String collectionName);
  Future<void> deleteResult(String collectionName, String documentId);
}
