import 'dart:async';

import '../models/post_model.dart';
import 'post_datasource.dart';

// The local data source: keeps posts in memory instead of Firestore.
// PostDataSourceFactory hands this one out when asked for local mode
// (offline or demo use), the rest of the app doesn't know or care since
// it only ever sees the PostDataSource interface.
class LocalPostDataSource implements PostDataSource {
  final List<PostModel> _posts = [];
  final _controller = StreamController<List<PostModel>>.broadcast();

  @override
  Stream<List<PostModel>> watchPosts() async* {
    yield List.unmodifiable(_posts);
    yield* _controller.stream;
  }

  @override
  Future<void> createPost(PostModel post) async {
    _posts.insert(0, post);
    _controller.add(List.unmodifiable(_posts));
  }
}
