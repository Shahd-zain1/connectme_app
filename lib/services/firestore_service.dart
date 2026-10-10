import 'package:cloud_firestore/cloud_firestore.dart';

// Singleton Pattern: the private constructor means FirestoreService can
// only ever be created once, through the static `instance` getter below,
// so every part of the app that touches Firestore shares the exact same
// wrapper rather than each creating its own.
class FirestoreService {
  FirestoreService._internal();

  static final FirestoreService instance = FirestoreService._internal();

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get postsCollection => firestore.collection('posts');

  CollectionReference<Map<String, dynamic>> get usersCollection => firestore.collection('users');
}
