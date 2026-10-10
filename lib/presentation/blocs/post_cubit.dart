import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/errors/failures.dart';
import '../../domain/entities/post.dart';
import '../../domain/usecases/create_post.dart';
import '../../domain/usecases/get_posts.dart';

abstract class PostState {
  const PostState();
}

class PostInitial extends PostState {
  const PostInitial();
}

class PostLoading extends PostState {
  const PostLoading();
}

class PostLoaded extends PostState {
  const PostLoaded(this.posts);

  final List<Post> posts;
}

class PostError extends PostState {
  const PostError(this.message);

  final String message;
}

// Subscribes to GetPosts' stream once and turns each emission into a
// PostState, CreatePost is a one-off call, the feed itself updates
// automatically afterward since it's a live Firestore stream underneath.
class PostCubit extends Cubit<PostState> {
  PostCubit(this._getPosts, this._createPost) : super(const PostInitial()) {
    _subscribe();
  }

  final GetPosts _getPosts;
  final CreatePost _createPost;
  StreamSubscription<List<Post>>? _subscription;

  void _subscribe() {
    emit(const PostLoading());
    _subscription = _getPosts().listen(
      (posts) => emit(PostLoaded(posts)),
      onError: (error) => emit(PostError(error is Failure ? error.message : 'Could not load posts.')),
    );
  }

  Future<void> createPost({required String authorName, required String content}) async {
    final post = Post(
      id: '',
      authorName: authorName,
      content: content,
      timestamp: DateTime.now(),
    );
    try {
      await _createPost(post);
    } on Failure catch (failure) {
      emit(PostError(failure.message));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
