// A plain, serializable error the domain/data layers throw instead of
// leaking Firebase's own exception types up into the presentation layer.
// Cubits catch these and turn the message straight into UI text.
class Failure {
  const Failure(this.message);

  final String message;

  @override
  String toString() => message;
}
