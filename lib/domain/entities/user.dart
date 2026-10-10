// Plain domain entity, no Firestore or JSON knowledge here at all, that
// belongs to UserModel in the data layer. Fields are nullable because
// the Builder Pattern (see UserBuilder) only sets what's actually known
// at each point in the app's flow, sign-up sets fullName/email only,
// the profile screen fills in photo/device info later.
class User {
  const User({
    required this.uid,
    this.fullName,
    this.email,
    this.photoBase64,
    this.deviceModel,
    this.osVersion,
  });

  final String uid;
  final String? fullName;
  final String? email;
  final String? photoBase64;
  final String? deviceModel;
  final String? osVersion;

  User copyWith({
    String? fullName,
    String? email,
    String? photoBase64,
    String? deviceModel,
    String? osVersion,
  }) {
    return User(
      uid: uid,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      photoBase64: photoBase64 ?? this.photoBase64,
      deviceModel: deviceModel ?? this.deviceModel,
      osVersion: osVersion ?? this.osVersion,
    );
  }
}
