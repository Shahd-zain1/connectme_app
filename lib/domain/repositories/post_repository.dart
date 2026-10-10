import '../entities/post.dart';

// The domain layer only knows this contract, not how posts are actually
// fetched or stored, PostRepositoryImpl in the data layer is the one
// that decides that (and does so via the Factory Pattern, see
// PostDataSourceFactory).
abstract class PostRepository {
  Stream<List<Post>> watchPosts();

  Future<void> createPost(Post post);
}
