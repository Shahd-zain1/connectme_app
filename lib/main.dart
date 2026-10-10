import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'firebase_options.dart';
import 'injection.dart';
import 'presentation/blocs/auth_cubit.dart';
import 'presentation/blocs/post_cubit.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  configureDependencies();
  runApp(const ConnectMeApp());
}

class ConnectMeApp extends StatelessWidget {
  const ConnectMeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthCubit>.value(
      value: getIt<AuthCubit>(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'ConnectMe',
        theme: ThemeData(colorSchemeSeed: Colors.deepPurple, useMaterial3: true),
        home: const _AuthGate(),
      ),
    );
  }
}

// Watches AuthCubit and shows the login screen or the home feed based on
// its state, this is what makes an already-signed-in user skip straight
// to the feed on a fresh app launch, since AuthCubit's first emitted
// state comes from FirebaseAuth's own persisted session.
class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          return BlocProvider<PostCubit>(
            create: (context) => getIt<PostCubit>(),
            child: const HomeScreen(),
          );
        }
        if (state is Unauthenticated || state is AuthError) {
          return const LoginScreen();
        }
        // AuthInitial / AuthLoading: still waiting on the first auth-state
        // event, which arrives almost immediately either way.
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
