import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/errors/failures.dart';
import '../data/models/user_model.dart';
import '../domain/entities/user.dart';
import 'firestore_service.dart';

// Reads and writes the signed-in user's document in the "users"
// collection, through the FirestoreService singleton. Kept as its own
// small service so the Cubits never touch Firestore directly.
class UserProfileService {
  UserProfileService({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService.instance;

  final FirestoreService _firestoreService;

  Future<User?> fetchProfile(String uid) async {
    try {
      final document = await _firestoreService.usersCollection.doc(uid).get();
      final data = document.data();
      if (data == null) return null;
      return UserModel.fromJson(uid, data);
    } catch (_) {
      throw const Failure('Could not load your profile. Check your internet connection.');
    }
  }

  // merge: true means saving a partially built User (e.g. just after
  // sign-up, before a photo exists) only touches the fields it actually
  // has, it doesn't wipe fields that were saved earlier.
  Future<void> saveProfile(User user) async {
    try {
      await _firestoreService.usersCollection
          .doc(user.uid)
          .set(UserModel.fromEntity(user).toJson(), SetOptions(merge: true));
    } catch (_) {
      throw const Failure('Could not save your profile. Check your internet connection and try again.');
    }
  }
}
