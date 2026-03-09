package shared

type Role string

const (
	RoleKiller   Role = "killer"
	RoleDoctor   Role = "doctor"
	RoleVillager Role = "villager"
)

type RoomStatus string

const (
	RoomStatusLobby  RoomStatus = "lobby"
	RoomStatusInGame RoomStatus = "in_game"
	RoomStatusEnded  RoomStatus = "ended"
)

type GamePhase string

const (
	GamePhaseLobby        GamePhase = "lobby"
	GamePhaseRoleReveal   GamePhase = "role_reveal"
	GamePhaseNightKiller  GamePhase = "night_killer"
	GamePhaseNightDoctor  GamePhase = "night_doctor"
	GamePhaseNightResolve GamePhase = "night_resolve"
	GamePhaseDayReveal    GamePhase = "day_reveal"
	GamePhaseDiscussion   GamePhase = "discussion"
	GamePhaseVoting       GamePhase = "voting"
	GamePhaseVoteResult   GamePhase = "vote_result"
	GamePhaseEnded        GamePhase = "ended"
)

type WinnerType string

const (
	WinnerTypeNone      WinnerType = "none"
	WinnerTypeVillagers WinnerType = "villagers"
	WinnerTypeKillers   WinnerType = "killers"
)
