// Plain domain entity for a single community post. Like User, this
// knows nothing about Firestore, PostModel in the data layer handles
// the JSON shape.
class Post {
  const Post({
    required this.id,
    required this.authorName,
    required this.content,
    required this.timestamp,
  });

  final String id;
  final String authorName;
  final String content;
  final DateTime timestamp;
}
