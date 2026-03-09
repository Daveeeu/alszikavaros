class RoutePaths {
  const RoutePaths._();

  static const String splash = '/';
  static const String home = '/home';
  static const String createOrJoin = '/create-or-join';
  static const String join = '/join';
  static const String lobby = '/lobby/:roomCode';
  static const String roleReveal = '/game/:gameId/role';
  static const String waiting = '/game/:gameId/waiting';
  static const String nightAction = '/game/:gameId/night-action';
  static const String dayResult = '/game/:gameId/day-result';
  static const String discussion = '/game/:gameId/discussion';
  static const String voting = '/game/:gameId/voting';
  static const String voteResult = '/game/:gameId/vote-result';
  static const String end = '/game/:gameId/end';

  static String lobbyByCode(String roomCode) => '/lobby/$roomCode';
  static String roleRevealByGameId(String gameId) => '/game/$gameId/role';
  static String waitingByGameId(String gameId) => '/game/$gameId/waiting';
  static String nightActionByGameId(String gameId) => '/game/$gameId/night-action';
  static String dayResultByGameId(String gameId) => '/game/$gameId/day-result';
  static String discussionByGameId(String gameId) => '/game/$gameId/discussion';
  static String votingByGameId(String gameId) => '/game/$gameId/voting';
  static String voteResultByGameId(String gameId) => '/game/$gameId/vote-result';
  static String endByGameId(String gameId) => '/game/$gameId/end';
}
