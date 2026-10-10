import '../../core/errors/failures.dart';
import '../../services/firestore_service.dart';
import '../models/post_model.dart';
import 'post_datasource.dart';

// The remote data source: reads and writes posts straight to Cloud
// Firestore, through the FirestoreService singleton so there's only ever
// one Firestore wrapper in the whole app.
class FirestorePostDataSource implements PostDataSource {
  FirestorePostDataSource({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService.instance;

  final FirestoreService _firestoreService;

  @override
  Stream<List<PostModel>> watchPosts() {
    return _firestoreService.postsCollection
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => PostModel.fromJson(doc.id, doc.data())).toList())
        .handleError((_) => throw const Failure('Could not load posts. Check your internet connection.'));
  }

  @override
  Future<void> createPost(PostModel post) async {
    try {
      await _firestoreService.postsCollection.add(post.toJson());
    } catch (_) {
      throw const Failure('Could not save your post. Check your internet connection and try again.');
    }
  }
}
