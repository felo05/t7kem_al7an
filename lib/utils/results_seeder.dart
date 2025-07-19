import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class ResultsSeeder {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Collection names for results
  static const List<String> collections = [
    'kg1Results',
    'kg2Results', 
    'kgGResults',
    'kgFResults',
    'oulaTanya1Results',
    'oulaTanya2Results',
    'oulaTanyaGResults',
    'oulaTanyaFResults',
    'taltaRaba1Results',
    'taltaRaba2Results',
    'taltaRabaGResults',
    'taltaRabaFResults',
    'khamsaSadsa1Results',
    'khamsaSadsa2Results',
    'khamsaSadsaGResults',
    'khamsaSadsaFResults',
  ];

  // Sample church names (Arabic)
  static const List<String> churches = [
    'كنيسة مار جرجس',
    'كنيسة العذراء مريم',
    'كنيسة مار مينا',
    'كنيسة الشهيد مار مرقس',
    'كنيسة القديس يوحنا',
    'كنيسة الأنبا أنطونيوس',
    'كنيسة الملاك ميخائيل',
    'كنيسة الأنبا بيشوي',
    'كنيسة القديسة دميانة',
    'كنيسة الأنبا صموئيل',
    'كنيسة مار بولس',
    'كنيسة الأنبا كيرلس',
    'كنيسة القديس موسى',
    'كنيسة الأنبا برسوم',
    'كنيسة مار تادرس'
  ];

  // Sample contestant names (Arabic)
  static const List<String> contestants = [
    'أحمد محمد علي',
    'فاطمة سعد محمد',
    'محمد أحمد حسن',
    'سارة محمد إبراهيم',
    'عمر خالد أحمد',
    'نور الهدى حسام',
    'يوسف إبراهيم سمير',
    'مريم سمير جمال',
    'خالد أحمد فؤاد',
    'نادية حسن محمود',
    'إبراهيم عمر طارق',
    'ليلى محمود سعد',
    'سمير جمال نور',
    'هدى فؤاد عمر',
    'طارق سعد أحمد',
    'نرمين محمد علي',
    'حسام أحمد خالد',
    'دينا سمير حسن',
    'أمير محمود فؤاد',
    'رنا عمر جمال'
  ];

  static Map<String, dynamic> _createRandomDocument(String collectionName) {
    final random = Random();
    final church = churches[random.nextInt(churches.length)];
    
    // Generate random scores for different categories
    final memorizationScore = 70 + random.nextInt(31); // 70-100
    final understandingScore = 65 + random.nextInt(31); // 65-95
    final presentationScore = 60 + random.nextInt(31); // 60-90
    
    // Calculate total
    final total = memorizationScore + understandingScore + presentationScore;
    
    return {
      'church': church,
      'scores': {
        'memorization': memorizationScore,  // حفظ
        'understanding': understandingScore,  // فهم
        'presentation': presentationScore   // إلقاء
      },
      'total': total,
      'rank': 0,  // Will be calculated later
      'timestamp': FieldValue.serverTimestamp(),
      'collection_category': collectionName.replaceAll('Results', ''),
      'notes': 'بيانات تجريبية للاختبار', // Test data
    };
  }

  static Future<void> seedCollection(String collectionName, int numDocuments) async {
    print('🌱 Seeding $collectionName with $numDocuments documents...');
    
    try {
      // Create documents with random data
      List<Map<String, dynamic>> documents = [];
      for (int i = 0; i < numDocuments; i++) {
        documents.add(_createRandomDocument(collectionName));
      }
      
      // Sort by total score to assign ranks
      documents.sort((a, b) => b['total'].compareTo(a['total']));
      
      // Assign ranks and save to Firestore
      WriteBatch batch = _firestore.batch();
      for (int i = 0; i < documents.length; i++) {
        documents[i]['rank'] = i + 1;
        final docRef = _firestore.collection(collectionName).doc('contestant_${i + 1}');
        batch.set(docRef, documents[i]);
      }
      
      // Commit the batch
      await batch.commit();
      
      // Print summary
      final winner = documents.first;
      print('   ✅ Added ${documents.length} documents');
      print('   🏆 Winner: ${winner['contestant']} from ${winner['church']} (Total: ${winner['total']})');
      
    } catch (e) {
      print('❌ Error seeding $collectionName: $e');
    }
  }

  static Future<void> seedAllCollections() async {
    print('🚀 Starting Results Collections Seeding...');
    print('=' * 50);
    
    int totalDocuments = 0;
    final random = Random();
    
    for (String collectionName in collections) {
      try {
        // Random number of documents per collection (3-8)
        final numDocs = 3 + random.nextInt(6);
        await seedCollection(collectionName, numDocs);
        totalDocuments += numDocs;
        print('');
      } catch (e) {
        print('❌ Error with $collectionName: $e');
        continue;
      }
    }
    
    print('=' * 50);
    print('🎉 Seeding completed!');
    print('📊 Total documents created: $totalDocuments');
    print('📂 Collections seeded: ${collections.length}');
    print('\n💡 You can now test the CheckStatusScreen to see the results!');
  }

  static Future<void> clearAllResultsCollections() async {
    print('🧹 Clearing all Results collections...');
    
    for (String collectionName in collections) {
      try {
        final snapshot = await _firestore.collection(collectionName).get();
        WriteBatch batch = _firestore.batch();
        
        for (var doc in snapshot.docs) {
          batch.delete(doc.reference);
        }
        
        await batch.commit();
        print('   ✅ Cleared $collectionName (${snapshot.docs.length} documents)');
      } catch (e) {
        print('❌ Error clearing $collectionName: $e');
      }
    }
    
    print('🎉 All Results collections cleared!');
  }
}
