import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../blocs/profile_cubit.dart';
import '../widgets/profile_info_row.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _changePhoto(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, maxWidth: 512);
    if (pickedFile == null) return;

    // The task asks for the photo to be uploaded to Firestore specifically
    // (no Firebase Storage in the technology list), Firestore documents
    // can hold strings but not raw binary, so the image is base64-encoded
    // into a string field. Fine for a small profile picture, not something
    // to do for large images in a real production app.
    final bytes = await pickedFile.readAsBytes();
    final base64Image = base64Encode(bytes);

    if (!context.mounted) return;
    context.read<ProfileCubit>().updatePhoto(base64Image);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ProfileError) {
            return Center(child: Text(state.message, textAlign: TextAlign.center));
          }

          final loaded = state as ProfileLoaded;
          final user = loaded.user;
          final hasPhoto = user.photoBase64 != null;

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundImage: hasPhoto ? MemoryImage(base64Decode(user.photoBase64!)) : null,
                    child: hasPhoto ? null : const Icon(Icons.person, size: 48),
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: loaded.isUpdatingPhoto ? null : () => _changePhoto(context),
                    icon: const Icon(Icons.photo_camera_outlined),
                    label: Text(loaded.isUpdatingPhoto ? 'Updating...' : 'Change Photo'),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user.fullName ?? 'No name set',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(user.email ?? ''),
                  const Divider(height: 32),
                  ProfileInfoRow(label: 'Device', value: user.deviceModel ?? 'Unknown'),
                  ProfileInfoRow(label: 'OS Version', value: user.osVersion ?? 'Unknown'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
