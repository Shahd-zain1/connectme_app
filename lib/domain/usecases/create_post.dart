import '../entities/post.dart';
import '../repositories/post_repository.dart';

// Wraps "save a new post" as its own use case, same reasoning as
// GetPosts, PostCubit calls this rather than reaching into the
// repository directly.
class CreatePost {
  const CreatePost(this._repository);

  final PostRepository _repository;

  Future<void> call(Post post) => _repository.createPost(post);
}
