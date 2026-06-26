import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/injection_container.dart';
import 'core/routing/app_router.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  runApp(const HrApp());
}

class HrApp extends StatelessWidget {
  const HrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>(
      // Single app-wide AuthBloc instance. Every feature reads the current
      // user/role from this via context.read<AuthBloc>().state.
      create: (_) => sl<AuthBloc>()..add(const AuthCheckRequested()),
      child: Builder(
        builder: (context) {
          final router = buildRouter(context.read<AuthBloc>());
          return MaterialApp.router(
            title: 'HR Portal',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorSchemeSeed: Colors.indigo,
              useMaterial3: true,
            ),
            routerConfig: router,
          );
        },
      ),
    );
  }
}
