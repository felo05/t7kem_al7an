import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Service to initialize final result collections in Firestore
/// This runs on app initialization to ensure all required collections exist
class FinalCollectionsInitializer {
  static const String _initializationKey = 'final_collections_initialized';
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Collection names for all 16 final result collections
  static const List<String> _finalCollections = [
    // حضانة (Kindergarten)
    'kg1ResultsFinal',
    'kg2ResultsFinal',
    'kgGResultsFinal',
    'kgFResultsFinal',

    // أولى وثانية (1st and 2nd grade)
    'oulaTanya1ResultsFinal',
    'oulaTanya2ResultsFinal',
    'oulaTanyaGResultsFinal',
    'oulaTanyaFResultsFinal',

    // ثالثة ورابعة (3rd and 4th grade)
    'taltaRaba1ResultsFinal',
    'taltaRaba2ResultsFinal',
    'taltaRabaGResultsFinal',
    'taltaRabaFResultsFinal',

    // خامسة وسادسة (5th and 6th grade)
    'khamsaSadsa1ResultsFinal',
    'khamsaSadsa2ResultsFinal',
    'khamsaSadsaGResultsFinal',
    'khamsaSadsaFResultsFinal',
  ];

  /// Get human-readable Arabic description for each collection
  static String _getLevelDescription(String collectionName) {
    const Map<String, String> descriptions = {
      'kg1ResultsFinal': 'حضانة المستوى الأول - النتائج النهائية',
      'kg2ResultsFinal': 'حضانة المستوى الثاني - النتائج النهائية',
      'kgGResultsFinal': 'حضانة موهوبين جماعي - النتائج النهائية',
      'kgFResultsFinal': 'حضانة موهوبين فردي - النتائج النهائية',
      'oulaTanya1ResultsFinal': 'أولى وثانية المستوى الأول - النتائج النهائية',
      'oulaTanya2ResultsFinal': 'أولى وثانية المستوى الثاني - النتائج النهائية',
      'oulaTanyaGResultsFinal': 'أولى وثانية موهوبين جماعي - النتائج النهائية',
      'oulaTanyaFResultsFinal': 'أولى وثانية موهوبين فردي - النتائج النهائية',
      'taltaRaba1ResultsFinal': 'ثالثة ورابعة المستوى الأول - النتائج النهائية',
      'taltaRaba2ResultsFinal':
          'ثالثة ورابعة المستوى الثاني - النتائج النهائية',
      'taltaRabaGResultsFinal': 'ثالثة ورابعة موهوبين جماعي - النتائج النهائية',
      'taltaRabaFResultsFinal': 'ثالثة ورابعة موهوبين فردي - النتائج النهائية',
      'khamsaSadsa1ResultsFinal':
          'خامسة وسادسة المستوى الأول - النتائج النهائية',
      'khamsaSadsa2ResultsFinal':
          'خامسة وسادسة المستوى الثاني - النتائج النهائية',
      'khamsaSadsaGResultsFinal':
          'خامسة وسادسة موهوبين جماعي - النتائج النهائية',
      'khamsaSadsaFResultsFinal':
          'خامسة وسادسة موهوبين فردي - النتائج النهائية',
    };
    return descriptions[collectionName] ?? 'النتائج النهائية - $collectionName';
  }

  /// Check if final collections have already been initialized
  static Future<bool> _isAlreadyInitialized() async {
    try {
      final doc =
          await _firestore.collection('_system').doc(_initializationKey).get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return data['initialized'] == true;
      }
      return false;
    } catch (e) {
      debugPrint('Error checking initialization status: $e');
      return false;
    }
  }

  /// Mark final collections as initialized
  static Future<void> _markAsInitialized() async {
    try {
      await _firestore.collection('_system').doc(_initializationKey).set({
        'initialized': true,
        'initializedAt': FieldValue.serverTimestamp(),
        'version': '1.0',
        'collectionsCount': _finalCollections.length,
      });
    } catch (e) {
      debugPrint('Error marking as initialized: $e');
    }
  }

  /// Create a single final collection with its initial document
  static Future<bool> _createFinalCollection(String collectionName) async {
    try {
      // Check if the collection already has a 'final' document
      final docRef = _firestore.collection(collectionName).doc('final');
      final existingDoc = await docRef.get();

      if (existingDoc.exists) {
        debugPrint('✅ Collection $collectionName already exists');
        return true;
      }

      // Create the initial 'final' document
      final docData = {
        'day': 'final',
        'churches': <String>[], // Empty list to be populated later
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'description': _getLevelDescription(collectionName),
        'status': 'initialized',
        'totalChurches': 0,
        'version': '1.0',
      };

      await docRef.set(docData);
      debugPrint('✅ Created collection: $collectionName');
      return true;
    } catch (e) {
      debugPrint('❌ Error creating collection $collectionName: $e');
      return false;
    }
  }

  /// Verify that all collections exist and are properly configured
  static Future<bool> _verifyCollections() async {
    try {
      int verifiedCount = 0;

      for (final collectionName in _finalCollections) {
        final docRef = _firestore.collection(collectionName).doc('final');
        final doc = await docRef.get();

        if (doc.exists) {
          final data = doc.data();
          if (data != null &&
              data['day'] == 'final' &&
              data.containsKey('churches') &&
              data.containsKey('description')) {
            verifiedCount++;
          }
        }
      }

      final isValid = verifiedCount == _finalCollections.length;
      debugPrint(
          '📊 Verified $verifiedCount/${_finalCollections.length} collections');
      return isValid;
    } catch (e) {
      debugPrint('❌ Error verifying collections: $e');
      return false;
    }
  }

  /// Initialize all final result collections
  /// This method is idempotent and safe to call multiple times
  static Future<bool> initializeFinalCollections() async {
    try {
      debugPrint('🔥 Starting final collections initialization...');

      // Check if already initialized to avoid unnecessary work
      if (await _isAlreadyInitialized()) {
        debugPrint('✅ Final collections already initialized');
        return await _verifyCollections();
      }

      debugPrint(
          '🚀 Creating ${_finalCollections.length} final collections...');

      int successCount = 0;
      int errorCount = 0;

      // Create all collections
      for (final collectionName in _finalCollections) {
        final success = await _createFinalCollection(collectionName);
        if (success) {
          successCount++;
        } else {
          errorCount++;
        }
      }

      debugPrint('📊 Creation Summary:');
      debugPrint('   ✅ Success: $successCount collections');
      debugPrint('   ❌ Errors: $errorCount collections');

      // Verify all collections were created properly
      if (errorCount == 0) {
        final verified = await _verifyCollections();
        if (verified) {
          await _markAsInitialized();
          debugPrint('🎉 All final collections initialized successfully!');
          return true;
        } else {
          debugPrint('❌ Collection verification failed');
          return false;
        }
      } else {
        debugPrint('❌ Some collections failed to create');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Fatal error during initialization: $e');
      return false;
    }
  }

  /// Force re-initialization of all collections (for development/testing)
  static Future<bool> forceReinitialize() async {
    try {
      debugPrint('🔄 Force re-initializing final collections...');

      // Remove initialization marker
      await _firestore.collection('_system').doc(_initializationKey).delete();

      // Re-run initialization
      return await initializeFinalCollections();
    } catch (e) {
      debugPrint('❌ Error during force re-initialization: $e');
      return false;
    }
  }

  /// Get the current status of final collections initialization
  static Future<Map<String, dynamic>> getInitializationStatus() async {
    try {
      final isInitialized = await _isAlreadyInitialized();
      final verified = await _verifyCollections();

      return {
        'isInitialized': isInitialized,
        'isVerified': verified,
        'totalCollections': _finalCollections.length,
        'collectionNames': _finalCollections,
      };
    } catch (e) {
      debugPrint('❌ Error getting initialization status: $e');
      return {
        'isInitialized': false,
        'isVerified': false,
        'totalCollections': _finalCollections.length,
        'error': e.toString(),
      };
    }
  }

  /// Utility method to check if a specific final collection exists
  static Future<bool> doesFinalCollectionExist(String collectionName) async {
    try {
      if (!_finalCollections.contains(collectionName)) {
        return false;
      }

      final doc =
          await _firestore.collection(collectionName).doc('final').get();

      return doc.exists;
    } catch (e) {
      debugPrint('❌ Error checking collection $collectionName: $e');
      return false;
    }
  }

  /// Get all final collection names
  static List<String> getFinalCollectionNames() {
    return List.unmodifiable(_finalCollections);
  }
}
