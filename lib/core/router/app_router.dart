import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/game/presentation/screens/day_result_screen.dart';
import '../../features/game/presentation/screens/discussion_screen.dart';
import '../../features/game/presentation/screens/game_end_screen.dart';
import '../../features/game/presentation/screens/night_action_screen.dart';
import '../../features/game/presentation/screens/role_reveal_screen.dart';
import '../../features/game/presentation/screens/vote_result_screen.dart';
import '../../features/game/presentation/screens/voting_screen.dart';
import '../../features/game/presentation/screens/waiting_screen.dart';
import '../../features/home/presentation/screens/create_or_join_room_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/room/presentation/screens/join_room_screen.dart';
import '../../features/room/presentation/screens/lobby_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import 'route_paths.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: RoutePaths.splash,
    routes: [
      GoRoute(
        path: RoutePaths.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RoutePaths.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: RoutePaths.join,
        builder: (context, state) => const JoinRoomScreen(),
      ),
      GoRoute(
        path: RoutePaths.createOrJoin,
        builder: (context, state) => const CreateOrJoinRoomScreen(),
      ),
      GoRoute(
        path: RoutePaths.lobby,
        builder: (context, state) {
          final roomCode = state.pathParameters['roomCode'] ?? '';
          return LobbyScreen(roomCode: roomCode);
        },
      ),
      GoRoute(
        path: RoutePaths.roleReveal,
        builder: (context, state) {
          final gameId = state.pathParameters['gameId'] ?? '';
          return RoleRevealScreen(gameId: gameId);
        },
      ),
      GoRoute(
        path: RoutePaths.waiting,
        builder: (context, state) {
          final gameId = state.pathParameters['gameId'] ?? '';
          return WaitingScreen(gameId: gameId);
        },
      ),
      GoRoute(
        path: RoutePaths.nightAction,
        builder: (context, state) {
          final gameId = state.pathParameters['gameId'] ?? '';
          return NightActionScreen(gameId: gameId);
        },
      ),
      GoRoute(
        path: RoutePaths.dayResult,
        builder: (context, state) {
          final gameId = state.pathParameters['gameId'] ?? '';
          return DayResultScreen(gameId: gameId);
        },
      ),
      GoRoute(
        path: RoutePaths.discussion,
        builder: (context, state) {
          final gameId = state.pathParameters['gameId'] ?? '';
          return DiscussionScreen(gameId: gameId);
        },
      ),
      GoRoute(
        path: RoutePaths.voting,
        builder: (context, state) {
          final gameId = state.pathParameters['gameId'] ?? '';
          return VotingScreen(gameId: gameId);
        },
      ),
      GoRoute(
        path: RoutePaths.voteResult,
        builder: (context, state) {
          final gameId = state.pathParameters['gameId'] ?? '';
          return VoteResultScreen(gameId: gameId);
        },
      ),
      GoRoute(
        path: RoutePaths.end,
        builder: (context, state) {
          final gameId = state.pathParameters['gameId'] ?? '';
          return GameEndScreen(gameId: gameId);
        },
      ),
    ],
  );
});
