import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../injection.dart';
import '../../services/biometric_service.dart';
import '../blocs/auth_cubit.dart';
import '../blocs/post_cubit.dart';
import '../blocs/profile_cubit.dart';
import '../widgets/post_card.dart';
import 'map_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _currentUserName(BuildContext context) {
    final state = context.read<AuthCubit>().state;
    if (state is Authenticated) return state.user.fullName ?? state.user.email ?? 'Anonymous';
    return 'Anonymous';
  }

  Future<void> _openProfile(BuildContext context) async {
    final authState = context.read<AuthCubit>().state;
    if (authState is! Authenticated) return;

    final biometricService = getIt<BiometricService>();
    final authenticated = await biometricService.authenticate('Authenticate to view your profile');

    if (!context.mounted) return;

    if (!authenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fingerprint authentication failed')),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => getIt<ProfileCubit>()..loadProfile(authState.user),
          child: const ProfileScreen(),
        ),
      ),
    );
  }

  void _openMap(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const MapScreen()),
    );
  }

  void _openCreatePostSheet(BuildContext context) {
    final contentController = TextEditingController();
    final postCubit = context.read<PostCubit>();
    final authorName = _currentUserName(context);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('New Post', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(
                controller: contentController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: "What's on your mind?",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  final content = contentController.text.trim();
                  if (content.isEmpty) return;
                  postCubit.createPost(authorName: authorName, content: content);
                  Navigator.of(sheetContext).pop();
                },
                child: const Text('Post'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // MediaQuery keeps the feed's horizontal padding proportional on
    // wider screens (tablets) instead of a fixed value everywhere.
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth > 600 ? (screenWidth - 600) / 2 : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ConnectMe'),
        actions: [
          IconButton(
            icon: const Icon(Icons.map_outlined),
            tooltip: 'Community Map',
            onPressed: () => _openMap(context),
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            tooltip: 'Profile',
            onPressed: () => _openProfile(context),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Log Out',
            onPressed: () => context.read<AuthCubit>().signOut(),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: BlocBuilder<PostCubit, PostState>(
          builder: (context, state) {
            if (state is PostLoading || state is PostInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is PostError) {
              return Center(child: Text(state.message, textAlign: TextAlign.center));
            }
            final posts = (state as PostLoaded).posts;
            if (posts.isEmpty) {
              return const Center(child: Text('No posts yet, be the first to share something.'));
            }
            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: posts.length,
              itemBuilder: (context, index) => PostCard(post: posts[index]),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openCreatePostSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
