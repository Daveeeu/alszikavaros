package ws

import (
	"strings"
	"sync"
)

type Hub struct {
	mu       sync.RWMutex
	clients  map[*Client]struct{}
	roomSubs map[string]map[*Client]struct{}
	gameSubs map[string]map[*Client]struct{}
}

func NewHub() *Hub {
	return &Hub{
		clients:  make(map[*Client]struct{}),
		roomSubs: make(map[string]map[*Client]struct{}),
		gameSubs: make(map[string]map[*Client]struct{}),
	}
}

func (h *Hub) Register(c *Client) {
	h.mu.Lock()
	defer h.mu.Unlock()

	h.clients[c] = struct{}{}
	h.subscribeRoomLocked(c, c.roomCode)
	h.subscribeGameLocked(c, c.gameID)
}

func (h *Hub) Unregister(c *Client) {
	h.mu.Lock()
	defer h.mu.Unlock()

	if _, ok := h.clients[c]; !ok {
		return
	}
	delete(h.clients, c)

	for key, set := range h.roomSubs {
		delete(set, c)
		if len(set) == 0 {
			delete(h.roomSubs, key)
		}
	}
	for key, set := range h.gameSubs {
		delete(set, c)
		if len(set) == 0 {
			delete(h.gameSubs, key)
		}
	}

	close(c.send)
}

func (h *Hub) SubscribeRoom(c *Client, roomCode string) {
	h.mu.Lock()
	defer h.mu.Unlock()
	h.subscribeRoomLocked(c, roomCode)
}

func (h *Hub) SubscribeGame(c *Client, gameID string) {
	h.mu.Lock()
	defer h.mu.Unlock()
	h.subscribeGameLocked(c, gameID)
}

func (h *Hub) Broadcast(payload []byte) {
	h.mu.RLock()
	defer h.mu.RUnlock()

	for c := range h.clients {
		h.sendLocked(c, payload)
	}
}

func (h *Hub) BroadcastRoom(roomCode string, payload []byte) {
	normalized := normalizeKey(roomCode)
	if normalized == "" {
		return
	}

	h.mu.RLock()
	defer h.mu.RUnlock()

	for c := range h.roomSubs[normalized] {
		h.sendLocked(c, payload)
	}
}

func (h *Hub) BroadcastGame(gameID string, payload []byte) {
	normalized := normalizeKey(gameID)
	if normalized == "" {
		return
	}

	h.mu.RLock()
	defer h.mu.RUnlock()

	for c := range h.gameSubs[normalized] {
		h.sendLocked(c, payload)
	}
}

func (h *Hub) subscribeRoomLocked(c *Client, roomCode string) {
	code := normalizeKey(roomCode)
	if code == "" {
		return
	}
	if h.roomSubs[code] == nil {
		h.roomSubs[code] = make(map[*Client]struct{})
	}
	h.roomSubs[code][c] = struct{}{}
	c.roomCode = code
}

func (h *Hub) subscribeGameLocked(c *Client, gameID string) {
	id := normalizeKey(gameID)
	if id == "" {
		return
	}
	if h.gameSubs[id] == nil {
		h.gameSubs[id] = make(map[*Client]struct{})
	}
	h.gameSubs[id][c] = struct{}{}
	c.gameID = id
}

func (h *Hub) sendLocked(c *Client, payload []byte) {
	select {
	case c.send <- payload:
	default:
	}
}

func normalizeKey(input string) string {
	return strings.ToUpper(strings.TrimSpace(input))
}
