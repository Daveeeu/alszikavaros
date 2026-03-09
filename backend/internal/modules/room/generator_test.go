package room

import (
	"strings"
	"testing"
)

func TestRandomRoomCode_LengthAndCharset(t *testing.T) {
	code, err := randomRoomCode(6)
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if len(code) != 6 {
		t.Fatalf("expected code length 6, got %d", len(code))
	}

	for _, ch := range code {
		if !strings.ContainsRune(codeCharset, ch) {
			t.Fatalf("room code contains invalid character: %q", ch)
		}
	}
}

func TestRandomRoomCode_InvalidLength(t *testing.T) {
	_, err := randomRoomCode(0)
	if err == nil {
		t.Fatal("expected error for invalid length, got nil")
	}
}
