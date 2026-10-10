import '../../domain/entities/user.dart';

// Data-layer counterpart to the domain User entity, fromJson/toJson are
// the only place that knows the Firestore document shape for a user.
class UserModel extends User {
  const UserModel({
    required super.uid,
    super.fullName,
    super.email,
    super.photoBase64,
    super.deviceModel,
    super.osVersion,
  });

  factory UserModel.fromJson(String uid, Map<String, dynamic> json) {
    return UserModel(
      uid: uid,
      fullName: json['fullName'] as String?,
      email: json['email'] as String?,
      photoBase64: json['photoBase64'] as String?,
      deviceModel: json['deviceModel'] as String?,
      osVersion: json['osVersion'] as String?,
    );
  }

  // Only includes fields that are actually set, so a partially-built
  // User (e.g. straight after sign-up, before a photo is picked) doesn't
  // overwrite existing Firestore fields with nulls.
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (fullName != null) json['fullName'] = fullName;
    if (email != null) json['email'] = email;
    if (photoBase64 != null) json['photoBase64'] = photoBase64;
    if (deviceModel != null) json['deviceModel'] = deviceModel;
    if (osVersion != null) json['osVersion'] = osVersion;
    return json;
  }

  factory UserModel.fromEntity(User user) {
    return UserModel(
      uid: user.uid,
      fullName: user.fullName,
      email: user.email,
      photoBase64: user.photoBase64,
      deviceModel: user.deviceModel,
      osVersion: user.osVersion,
    );
  }
}
