import 'package:cloud_firestore/cloud_firestore.dart';

class GlobalChallengeService {
  static final _firestore = FirebaseFirestore.instance;
  static const String _collectionPath = "global_stats";
  static const String _docId = "today_challenge";

  /// تحديث عداد الأذكار العالمي
  static Future<void> incrementGlobalCounter(int count) async {
    try {
      final docRef = _firestore.collection(_collectionPath).doc(_docId);
      await docRef.set({
        'total_count': FieldValue.increment(count),
        'last_update': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print("Error updating global counter: $e");
    }
  }

  /// الاستماع المباشر لعداد الأذكار العالمي
  static Stream<int> getGlobalCounterStream() {
    return _firestore
        .collection(_collectionPath)
        .doc(_docId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        return snapshot.data()?['total_count'] ?? 0;
      }
      return 0;
    });
  }
}
