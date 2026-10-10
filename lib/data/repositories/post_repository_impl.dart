import '../../domain/entities/post.dart';
import '../../domain/repositories/post_repository.dart';
import '../datasources/post_datasource.dart';
import '../datasources/post_datasource_factory.dart';
import '../models/post_model.dart';

// Factory Pattern in use: this class never says "FirestorePostDataSource"
// or "LocalPostDataSource" itself, it just asks PostDataSourceFactory
// for whichever one useRemote calls for, then talks to it through the
// PostDataSource interface only.
class PostRepositoryImpl implements PostRepository {
  PostRepositoryImpl({bool useRemote = true, PostDataSource? dataSource})
      : _dataSource = dataSource ?? PostDataSourceFactory.create(useRemote: useRemote);

  final PostDataSource _dataSource;

  @override
  Stream<List<Post>> watchPosts() => _dataSource.watchPosts();

  @override
  Future<void> createPost(Post post) => _dataSource.createPost(PostModel.fromEntity(post));
}
