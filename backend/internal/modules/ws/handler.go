package ws

import (
	"encoding/json"
	"fmt"
	"net/http"
	"strings"
	"time"

	"github.com/gorilla/websocket"
)

const (
	writeWait      = 10 * time.Second
	pongWait       = 60 * time.Second
	pingPeriod     = (pongWait * 9) / 10
	maxMessageSize = 2048
)

type Client struct {
	id           string
	playerID     string
	sessionToken string
	roomCode     string
	gameID       string
	conn         *websocket.Conn
	send         chan []byte
}

type subscribeMessage struct {
	Action   string `json:"action"`
	RoomCode string `json:"roomCode"`
	GameID   string `json:"gameId"`
}

type connectedPayload struct {
	ClientID string `json:"clientId"`
	RoomCode string `json:"roomCode,omitempty"`
	GameID   string `json:"gameId,omitempty"`
}

type Handler struct {
	hub            *Hub
	allowedOrigins map[string]struct{}
	allowAnyOrigin bool
	upgrader       websocket.Upgrader
}

func NewHandler(hub *Hub, allowedOrigins []string) *Handler {
	originsMap := make(map[string]struct{}, len(allowedOrigins))
	allowAny := false
	for _, origin := range allowedOrigins {
		o := strings.TrimSpace(origin)
		if o == "" {
			continue
		}
		if o == "*" {
			allowAny = true
			continue
		}
		originsMap[o] = struct{}{}
	}

	h := &Handler{
		hub:            hub,
		allowedOrigins: originsMap,
		allowAnyOrigin: allowAny,
	}

	h.upgrader = websocket.Upgrader{
		ReadBufferSize:  1024,
		WriteBufferSize: 1024,
		CheckOrigin:     h.checkOrigin,
	}

	return h
}

func (h *Handler) checkOrigin(r *http.Request) bool {
	if h.allowAnyOrigin {
		return true
	}
	origin := strings.TrimSpace(r.Header.Get("Origin"))
	if origin == "" {
		return true
	}
	_, ok := h.allowedOrigins[origin]
	return ok
}

func (h *Handler) ServeWS(w http.ResponseWriter, r *http.Request) {
	conn, err := h.upgrader.Upgrade(w, r, nil)
	if err != nil {
		return
	}

	roomCode := normalizeKey(r.URL.Query().Get("roomCode"))
	gameID := normalizeKey(r.URL.Query().Get("gameId"))
	sessionToken := strings.TrimSpace(r.URL.Query().Get("sessionToken"))
	playerID := strings.TrimSpace(r.URL.Query().Get("playerId"))
	if sessionToken == "" {
		sessionToken = strings.TrimSpace(r.Header.Get("X-Session-Token"))
	}

	clientID := fmt.Sprintf("ws-%d", time.Now().UnixNano())
	if sessionToken != "" {
		clientID = "session-" + sessionToken
	}

	client := &Client{
		id:           clientID,
		playerID:     playerID,
		sessionToken: sessionToken,
		roomCode:     roomCode,
		gameID:       gameID,
		conn:         conn,
		send:         make(chan []byte, 64),
	}

	h.hub.Register(client)
	h.sendConnectedEvent(client)

	go h.writePump(client)
	h.readPump(client)
}

func (h *Handler) readPump(c *Client) {
	defer func() {
		h.hub.Unregister(c)
		_ = c.conn.Close()
	}()

	c.conn.SetReadLimit(maxMessageSize)
	_ = c.conn.SetReadDeadline(time.Now().Add(pongWait))
	c.conn.SetPongHandler(func(string) error {
		_ = c.conn.SetReadDeadline(time.Now().Add(pongWait))
		return nil
	})

	for {
		_, message, err := c.conn.ReadMessage()
		if err != nil {
			break
		}
		h.handleIncoming(c, message)
	}
}

func (h *Handler) handleIncoming(c *Client, message []byte) {
	var msg subscribeMessage
	if err := json.Unmarshal(message, &msg); err != nil {
		return
	}

	action := strings.ToLower(strings.TrimSpace(msg.Action))
	switch action {
	case "subscribe":
		if msg.RoomCode != "" {
			h.hub.SubscribeRoom(c, msg.RoomCode)
		}
		if msg.GameID != "" {
			h.hub.SubscribeGame(c, msg.GameID)
		}
		h.sendConnectedEvent(c)
	case "ping":
		h.sendControlEvent(c, "ws.pong", map[string]any{"ts": time.Now().UTC()})
	default:
		return
	}
}

func (h *Handler) writePump(c *Client) {
	ticker := time.NewTicker(pingPeriod)
	defer func() {
		ticker.Stop()
		_ = c.conn.Close()
	}()

	for {
		select {
		case msg, ok := <-c.send:
			if !ok {
				_ = c.conn.WriteControl(websocket.CloseMessage, []byte{}, time.Now().Add(writeWait))
				return
			}
			_ = c.conn.SetWriteDeadline(time.Now().Add(writeWait))
			if err := c.conn.WriteMessage(websocket.TextMessage, msg); err != nil {
				return
			}
		case <-ticker.C:
			_ = c.conn.SetWriteDeadline(time.Now().Add(writeWait))
			if err := c.conn.WriteMessage(websocket.PingMessage, nil); err != nil {
				return
			}
		}
	}
}

func (h *Handler) sendConnectedEvent(c *Client) {
	h.sendControlEvent(c, "ws.connected", connectedPayload{
		ClientID: c.id,
		RoomCode: c.roomCode,
		GameID:   c.gameID,
	})
}

func (h *Handler) sendControlEvent(c *Client, eventName string, payload any) {
	body, err := encodeEnvelope(eventName, payload)
	if err != nil {
		return
	}
	select {
	case c.send <- body:
	default:
	}
}
