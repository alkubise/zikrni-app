import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/app_user.dart';

class AuthService {
  AuthService._();

  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // تعريف GoogleSignIn بشكل يتوافق مع الإصدارات الحديثة
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  static User? get currentFirebaseUser => _auth.currentUser;
  static User? get currentUser => _auth.currentUser;
  static bool get isLoggedIn => _auth.currentUser != null;

  static Future<AppUser> signInWithGoogle() async {
    try {
      // في الإصدارات الحديثة، يفضل عمل signOut قبل الـ signIn لضمان ظهور واجهة اختيار الحساب
      await _googleSignIn.signOut().catchError((_) => null);

      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw 'تم إلغاء عملية الدخول';

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final result = await _auth.signInWithCredential(credential);
      final user = result.user;

      if (user == null) throw 'فشل الحصول على بيانات المستخدم من جوجل';

      return await _ensureUserDocument(
        uid: user.uid,
        name: user.displayName ?? 'مستخدم جديد',
        email: user.email ?? '',
        provider: 'Google',
        isGuest: false,
      );
    } catch (e) {
      if (e.toString().contains('10')) {
        throw 'خطأ 10: بصمة SHA-1 غير متطابقة في Firebase. تأكد من إضافة البصمة وتحديث ملف json.';
      }
      rethrow;
    }
  }

  static Future<AppUser> continueAsGuest() async {
    try {
      final credential = await _auth.signInAnonymously();
      final user = credential.user;

      if (user != null) {
        return await _ensureUserDocument(
          uid: user.uid,
          name: 'ضيف-${Random().nextInt(9999)}',
          email: '',
          provider: 'Guest',
          isGuest: true,
        );
      }
      throw 'فشل مجهول';
    } catch (e) {
      print('Firebase Guest Auth Failed: $e. Falling back to Local Guest.');
      return AppUser(
        uid: 'local_guest_${DateTime.now().millisecondsSinceEpoch}',
        name: 'ضيف (محلي)',
        email: '',
        provider: 'Local',
        joinDate: DateTime.now().toIso8601String(),
        bestTime: 'لا يوجد',
        spiritualLevel: 'مبتدئ',
        isGuest: true,
        smartModeEnabled: true,
        streakDays: 0,
        totalAzkar: 0,
        dailyGoal: 100,
      );
    }
  }

  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    await _auth.signOut();
  }

  static Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) return;

    // 1. Delete Firestore User Document
    await _firestore.collection('users').doc(user.uid).delete();
    
    // 2. Delete Subcollections if needed (optional but recommended)
    final events = await _firestore.collection('users').doc(user.uid).collection('events').get();
    for (var doc in events.docs) {
      await doc.reference.delete();
    }

    // 3. Delete Auth User
    await user.delete();
    
    // 4. Final Sign Out
    await signOut();
  }

  static Future<AppUser?> getCurrentAppUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists || doc.data() == null) return null;
      return AppUser.fromJson(doc.data()!);
    } catch (e) {
      return null;
    }
  }

  static Future<void> updateUserProfile({
    required String uid,
    required String name,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).set(
        {
          'name': name,
          'lastSeenAt': DateTime.now().toIso8601String(),
        },
        SetOptions(merge: true),
      );
    } catch (_) {}
  }

  static Future<AppUser> _ensureUserDocument({
    required String uid,
    required String name,
    required String email,
    required String provider,
    required bool isGuest,
  }) async {
    try {
      final ref = _firestore.collection('users').doc(uid);
      final snapshot = await ref.get().timeout(const Duration(seconds: 5));

      if (snapshot.exists && snapshot.data() != null) {
        return AppUser.fromJson(snapshot.data()!);
      }

      final user = AppUser(
        uid: uid,
        name: name,
        email: email,
        provider: provider,
        joinDate: DateTime.now().toIso8601String(),
        bestTime: 'لا يوجد',
        spiritualLevel: 'مبتدئ بنور الله',
        isGuest: isGuest,
        smartModeEnabled: true,
        streakDays: 0,
        totalAzkar: 0,
        dailyGoal: 100,
      );

      await ref.set(user.toJson(), SetOptions(merge: true));
      return user;
    } catch (e) {
      return AppUser(
        uid: uid,
        name: name,
        email: email,
        provider: provider,
        isGuest: isGuest,
        joinDate: DateTime.now().toIso8601String(),
        bestTime: 'لا يوجد',
        spiritualLevel: 'مبتدئ',
        smartModeEnabled: true,
        streakDays: 0,
        totalAzkar: 0,
        dailyGoal: 100,
      );
    }
  }
}
