import 'package:go_router/go_router.dart';
import 'package:push_app/presentation/screen/details_screen.dart';
import 'package:push_app/presentation/screen/home_screen.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (_, __) => const HomeScreen(),
    ),

    GoRoute(
      path: '/details/:messageId',
      builder:(context, state) => DetailsScreen(pushMessageId: state.pathParameters['messageId'] ?? ''),
    ),
  ]
);