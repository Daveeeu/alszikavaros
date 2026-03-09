package auth

import (
	"context"
	"net/http"

	"github.com/Daveeeu/alszikavaros/backend/internal/modules/player"
)

type ctxKey string

const (
	ctxKeyCurrentPlayer     ctxKey = "current_player"
	ctxKeyCurrentRoomID     ctxKey = "current_room_id"
	ctxKeyCurrentRoomHostID ctxKey = "current_room_host_id"
	ctxKeySessionToken      ctxKey = "session_token"
)

func withCurrentPlayer(ctx context.Context, p *player.Player) context.Context {
	return context.WithValue(ctx, ctxKeyCurrentPlayer, p)
}

func withCurrentRoom(ctx context.Context, roomID string, roomHostID string) context.Context {
	ctx = context.WithValue(ctx, ctxKeyCurrentRoomID, roomID)
	ctx = context.WithValue(ctx, ctxKeyCurrentRoomHostID, roomHostID)
	return ctx
}

func withSessionToken(ctx context.Context, token string) context.Context {
	return context.WithValue(ctx, ctxKeySessionToken, token)
}

func CurrentPlayer(r *http.Request) (*player.Player, bool) {
	p, ok := r.Context().Value(ctxKeyCurrentPlayer).(*player.Player)
	return p, ok && p != nil
}

func CurrentRoomID(r *http.Request) (string, bool) {
	roomID, ok := r.Context().Value(ctxKeyCurrentRoomID).(string)
	return roomID, ok && roomID != ""
}

func CurrentRoomHostID(r *http.Request) (string, bool) {
	hostID, ok := r.Context().Value(ctxKeyCurrentRoomHostID).(string)
	return hostID, ok
}

func CurrentSessionToken(r *http.Request) (string, bool) {
	token, ok := r.Context().Value(ctxKeySessionToken).(string)
	return token, ok && token != ""
}
