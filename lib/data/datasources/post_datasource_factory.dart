import 'firestore_post_datasource.dart';
import 'local_post_datasource.dart';
import 'post_datasource.dart';

// Factory Pattern: the one place that decides which concrete data source
// to build. PostRepositoryImpl asks for a PostDataSource and gets back
// either the remote Firestore one or the local one, without ever naming
// either class itself, so swapping or adding a data source later only
// touches this file.
class PostDataSourceFactory {
  const PostDataSourceFactory._();

  static PostDataSource create({required bool useRemote}) {
    if (useRemote) {
      return FirestorePostDataSource();
    }
    return LocalPostDataSource();
  }
}
