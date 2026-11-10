import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sprint/app/router/app_router.dart';

part 'router_provider.g.dart';

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) => buildAppRouter();
