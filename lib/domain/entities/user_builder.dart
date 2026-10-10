import 'user.dart';

// Builder Pattern: constructs a User one field at a time, and only the
// fields actually provided end up set, everything else stays null. At
// sign-up AuthCubit only calls setFullName and setEmail, so the built
// User has no photo or device info yet, ProfileCubit adds those later.
// A constructor with five optional named args could do the same job, but
// the builder makes it obvious at each call site exactly which fields
// this particular User is being given.
class UserBuilder {
  UserBuilder(this._uid);

  final String _uid;
  String? _fullName;
  String? _email;
  String? _photoBase64;
  String? _deviceModel;
  String? _osVersion;

  UserBuilder setFullName(String fullName) {
    _fullName = fullName;
    return this;
  }

  UserBuilder setEmail(String email) {
    _email = email;
    return this;
  }

  UserBuilder setPhotoBase64(String photoBase64) {
    _photoBase64 = photoBase64;
    return this;
  }

  UserBuilder setDeviceModel(String deviceModel) {
    _deviceModel = deviceModel;
    return this;
  }

  UserBuilder setOsVersion(String osVersion) {
    _osVersion = osVersion;
    return this;
  }

  User build() {
    return User(
      uid: _uid,
      fullName: _fullName,
      email: _email,
      photoBase64: _photoBase64,
      deviceModel: _deviceModel,
      osVersion: _osVersion,
    );
  }
}
