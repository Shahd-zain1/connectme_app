import '../models/post_model.dart';

// The common shape both data sources follow, PostRepositoryImpl only
// ever talks to this interface, never to a concrete class, which is
// what lets PostDataSourceFactory hand it either implementation.
abstract class PostDataSource {
  Stream<List<PostModel>> watchPosts();

  Future<void> createPost(PostModel post);
}
