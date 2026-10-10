import '../entities/post.dart';
import '../repositories/post_repository.dart';

// Wraps "watch the post feed" as its own use case so PostCubit depends
// on this single-purpose class instead of the whole PostRepository
// interface, standard Clean Architecture separation between what the
// presentation layer needs and what the repository can do.
class GetPosts {
  const GetPosts(this._repository);

  final PostRepository _repository;

  Stream<List<Post>> call() => _repository.watchPosts();
}
