import 'package:get_it/get_it.dart';
import 'package:t7kem_al7an/features/authentication/repository/authentication_repository.dart';

import '../../features/authentication/repository/i_authentication_repository.dart';

final GetIt sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  sl.registerLazySingleton<IAuthenticationRepository>(()=>AuthenticationRepository());
}