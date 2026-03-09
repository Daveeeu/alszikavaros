package auth

import (
	"errors"
	"net/http"
	"strings"

	"github.com/Daveeeu/alszikavaros/backend/internal/modules/player"
	"github.com/Daveeeu/alszikavaros/backend/internal/shared"
	"github.com/go-chi/chi/v5"
	"gorm.io/gorm"
)

const SessionTokenHeader = "X-Session-Token"

type roomRecord struct {
	ID           string  `gorm:"column:id"`
	HostPlayerID *string `gorm:"column:host_player_id"`
}

func RequireSession(db *gorm.DB) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			token := strings.TrimSpace(r.Header.Get(SessionTokenHeader))
			if token == "" {
				shared.Fail(w, r, http.StatusUnauthorized, "missing session token")
				return
			}

			var p player.Player
			if err := db.Where("session_token = ?", token).First(&p).Error; err != nil {
				if errors.Is(err, gorm.ErrRecordNotFound) {
					shared.Fail(w, r, http.StatusUnauthorized, "invalid session token")
					return
				}
				shared.Fail(w, r, http.StatusInternalServerError, "internal server error")
				return
			}

			ctx := withCurrentPlayer(r.Context(), &p)
			ctx = withSessionToken(ctx, token)
			next.ServeHTTP(w, r.WithContext(ctx))
		})
	}
}

func RequireRoomMembershipByCode(db *gorm.DB) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			currentPlayer, ok := CurrentPlayer(r)
			if !ok {
				shared.Fail(w, r, http.StatusUnauthorized, "unauthorized")
				return
			}

			roomCode := strings.ToUpper(strings.TrimSpace(chi.URLParam(r, "code")))
			if roomCode == "" {
				shared.Fail(w, r, http.StatusBadRequest, "missing room code")
				return
			}

			var rm roomRecord
			if err := db.Table("rooms").Select("id, host_player_id").Where("code = ?", roomCode).First(&rm).Error; err != nil {
				if errors.Is(err, gorm.ErrRecordNotFound) {
					shared.Fail(w, r, http.StatusNotFound, "room not found")
					return
				}
				shared.Fail(w, r, http.StatusInternalServerError, "internal server error")
				return
			}

			if currentPlayer.RoomID != rm.ID {
				shared.Fail(w, r, http.StatusForbidden, "player not in room")
				return
			}

			hostID := ""
			if rm.HostPlayerID != nil {
				hostID = *rm.HostPlayerID
			}
			ctx := withCurrentRoom(r.Context(), rm.ID, hostID)
			next.ServeHTTP(w, r.WithContext(ctx))
		})
	}
}

func RequireHostOfCurrentRoom() func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			currentPlayer, ok := CurrentPlayer(r)
			if !ok {
				shared.Fail(w, r, http.StatusUnauthorized, "unauthorized")
				return
			}
			roomHostID, ok := CurrentRoomHostID(r)
			if !ok {
				shared.Fail(w, r, http.StatusForbidden, "room context missing")
				return
			}

			if !currentPlayer.IsHost {
				shared.Fail(w, r, http.StatusForbidden, "host access required")
				return
			}
			if roomHostID == "" || roomHostID != currentPlayer.ID {
				shared.Fail(w, r, http.StatusForbidden, "only host can perform this action")
				return
			}

			next.ServeHTTP(w, r)
		})
	}
}
