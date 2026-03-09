package server

import (
	"net/http"

	"github.com/Daveeeu/alszikavaros/backend/internal/auth"
	"github.com/Daveeeu/alszikavaros/backend/internal/config"
	"github.com/Daveeeu/alszikavaros/backend/internal/modules/action"
	"github.com/Daveeeu/alszikavaros/backend/internal/modules/game"
	"github.com/Daveeeu/alszikavaros/backend/internal/modules/player"
	"github.com/Daveeeu/alszikavaros/backend/internal/modules/room"
	"github.com/Daveeeu/alszikavaros/backend/internal/modules/vote"
	"github.com/Daveeeu/alszikavaros/backend/internal/modules/ws"
	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
	"github.com/go-chi/cors"
	"gorm.io/gorm"
)

func newRouter(cfg *config.Config, db *gorm.DB, wsHub *ws.Hub) http.Handler {
	r := chi.NewRouter()

	r.Use(middleware.RequestID)
	r.Use(middleware.RealIP)
	r.Use(requestLogger)
	r.Use(recoverer)
	r.Use(cors.Handler(cors.Options{
		AllowedOrigins:   cfg.CORSAllowedOrigins,
		AllowedMethods:   []string{"GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"},
		AllowedHeaders:   []string{"Accept", "Authorization", "Content-Type", "X-CSRF-Token", auth.SessionTokenHeader},
		ExposedHeaders:   []string{"Link"},
		AllowCredentials: true,
		MaxAge:           300,
	}))

	r.Get("/health", healthHandler)

	playerHandler := player.NewHandler(player.NewService(player.NewRepository(db)))
	gameRepo := game.NewRepository(db)
	gameEngine := game.NewGameStateEngine(gameRepo)
	wsPublisher := ws.NewPublisher(wsHub)
	gameHandler := game.NewHandler(game.NewService(gameRepo), wsPublisher)
	roomHandler := room.NewHandler(
		room.NewService(
			room.NewRepository(db),
			game.NewStartService(gameRepo, game.NewRoleAssignmentService()),
			gameRepo,
		),
		wsPublisher,
	)
	voteHandler := vote.NewHandler(vote.NewService(vote.NewRepository(db), gameRepo, gameEngine), wsPublisher)
	actionHandler := action.NewHandler(
		action.NewService(
			action.NewRepository(db),
			gameRepo,
			gameEngine,
			action.DefaultTargetingRules(),
		),
	)
	wsHandler := ws.NewHandler(wsHub, cfg.WSAllowedOrigins)

	// Public room endpoints.
	r.Post("/rooms", roomHandler.CreateRoom)
	r.Post("/rooms/join", roomHandler.JoinRoom)

	// Protected room endpoints.
	r.With(auth.RequireSession(db), auth.RequireRoomMembershipByCode(db)).Get("/rooms/{code}", roomHandler.GetRoomByCode)
	r.With(auth.RequireSession(db), auth.RequireRoomMembershipByCode(db)).Post("/rooms/{code}/leave", roomHandler.LeaveRoom)
	r.With(auth.RequireSession(db), auth.RequireRoomMembershipByCode(db), auth.RequireHostOfCurrentRoom()).Post("/rooms/{code}/start", roomHandler.StartGame)
	r.With(auth.RequireSession(db), auth.RequireRoomMembershipByCode(db), auth.RequireHostOfCurrentRoom()).Post("/rooms/{code}/restart", roomHandler.RestartRoom)

	// Game endpoints require session.
	r.With(auth.RequireSession(db)).Get("/games/{id}/state", gameHandler.GetGameState)
	r.With(auth.RequireSession(db)).Post("/games/{id}/role/reveal", gameHandler.RevealRole)
	r.With(auth.RequireSession(db)).Post("/games/{id}/discussion/start", gameHandler.StartDiscussion)
	r.With(auth.RequireSession(db)).Post("/games/{id}/voting/start", gameHandler.StartVoting)
	r.With(auth.RequireSession(db)).Post("/games/{id}/actions", actionHandler.SubmitAction)
	r.With(auth.RequireSession(db)).Post("/games/{id}/votes", voteHandler.SubmitVote)

	player.RegisterRoutes(r, playerHandler)
	ws.RegisterRoutes(r, wsHandler)

	return r
}
