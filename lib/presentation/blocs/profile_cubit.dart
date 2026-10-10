import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/errors/failures.dart';
import '../../domain/entities/user.dart';
import '../../services/device_info_service.dart';
import '../../services/user_profile_service.dart';

abstract class ProfileState {
  const ProfileState();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  const ProfileLoaded(this.user, {this.isUpdatingPhoto = false});

  final User user;
  final bool isUpdatingPhoto;

  ProfileLoaded copyWith({User? user, bool? isUpdatingPhoto}) {
    return ProfileLoaded(
      user ?? this.user,
      isUpdatingPhoto: isUpdatingPhoto ?? this.isUpdatingPhoto,
    );
  }
}

class ProfileError extends ProfileState {
  const ProfileError(this.message);

  final String message;
}

// Loads the device model/OS version once (device_info_plus doesn't
// change mid-session) and merges it onto whatever User it's given,
// then handles updating the profile photo when the user picks a new one.
class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this._deviceInfoService, this._userProfileService) : super(const ProfileLoading());

  final DeviceInfoService _deviceInfoService;
  final UserProfileService _userProfileService;

  Future<void> loadProfile(User user) async {
    emit(const ProfileLoading());
    try {
      final deviceInfo = await _deviceInfoService.getDeviceInfo();
      final updated = user.copyWith(
        deviceModel: deviceInfo.modelName,
        osVersion: deviceInfo.osVersion,
      );
      // Saved so the device info shows up next time even before this
      // method runs again (e.g. viewed from a different session).
      await _userProfileService.saveProfile(updated);
      emit(ProfileLoaded(updated));
    } on Failure catch (failure) {
      emit(ProfileError(failure.message));
    }
  }

  Future<void> updatePhoto(String photoBase64) async {
    final state = this.state;
    if (state is! ProfileLoaded) return;

    emit(state.copyWith(isUpdatingPhoto: true));
    try {
      final updated = state.user.copyWith(photoBase64: photoBase64);
      await _userProfileService.saveProfile(updated);
      emit(ProfileLoaded(updated));
    } on Failure catch (failure) {
      emit(ProfileError(failure.message));
    }
  }
}
