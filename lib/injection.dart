import 'package:get_it/get_it.dart';

import 'data/repositories/post_repository_impl.dart';
import 'domain/repositories/post_repository.dart';
import 'domain/usecases/create_post.dart';
import 'domain/usecases/get_posts.dart';
import 'presentation/blocs/auth_cubit.dart';
import 'presentation/blocs/post_cubit.dart';
import 'presentation/blocs/profile_cubit.dart';
import 'services/auth_service.dart';
import 'services/biometric_service.dart';
import 'services/device_info_service.dart';
import 'services/firestore_service.dart';
import 'services/user_profile_service.dart';

final getIt = GetIt.instance;

// Every repository and use case gets registered here, in one place,
// instead of screens constructing their own dependencies. Services are
// registered as lazy singletons (one instance, created the first time
// something asks for it), Cubits as factories (a fresh instance each
// time one is requested, since each screen that uses one needs its own).
void configureDependencies() {
  // FirestoreService is already a Singleton by its own constructor (see
  // the class itself), registering the existing instance here just makes
  // it reachable through GetIt like everything else.
  getIt.registerSingleton<FirestoreService>(FirestoreService.instance);

  getIt.registerLazySingleton<AuthService>(() => AuthService());
  getIt.registerLazySingleton<BiometricService>(() => BiometricService());
  getIt.registerLazySingleton<DeviceInfoService>(() => DeviceInfoService());
  getIt.registerLazySingleton<UserProfileService>(() => UserProfileService());

  getIt.registerLazySingleton<PostRepository>(() => PostRepositoryImpl());
  getIt.registerFactory<GetPosts>(() => GetPosts(getIt<PostRepository>()));
  getIt.registerFactory<CreatePost>(() => CreatePost(getIt<PostRepository>()));

  // AuthCubit is a lazy singleton, not a factory, since the whole app's
  // routing (login screen vs. home feed) depends on everyone sharing the
  // exact same instance and its one auth-state subscription. A factory
  // here would hand out a fresh, independent AuthCubit to each caller.
  getIt.registerLazySingleton<AuthCubit>(
    () => AuthCubit(getIt<AuthService>(), getIt<UserProfileService>()),
  );
  getIt.registerFactory<PostCubit>(() => PostCubit(getIt<GetPosts>(), getIt<CreatePost>()));
  getIt.registerFactory<ProfileCubit>(() => ProfileCubit(getIt<DeviceInfoService>(), getIt<UserProfileService>()));
}
