import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/post.dart';

// Data-layer counterpart to the domain Post entity. Only this class
// knows Firestore's field names and timestamp type, fromJson/toJson are
// the single place that mapping happens.
class PostModel extends Post {
  const PostModel({
    required super.id,
    required super.authorName,
    required super.content,
    required super.timestamp,
  });

  factory PostModel.fromJson(String id, Map<String, dynamic> json) {
    final timestamp = json['timestamp'];
    return PostModel(
      id: id,
      authorName: json['authorName'] as String? ?? 'Unknown',
      content: json['content'] as String? ?? '',
      timestamp: timestamp is Timestamp ? timestamp.toDate() : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'authorName': authorName,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  factory PostModel.fromEntity(Post post) {
    return PostModel(
      id: post.id,
      authorName: post.authorName,
      content: post.content,
      timestamp: post.timestamp,
    );
  }
}
