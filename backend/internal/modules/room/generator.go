package room

import (
	"crypto/rand"
	"encoding/base64"
	"fmt"
	"math/big"
	"strconv"
	"strings"
	"time"
)

const codeCharset = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"

func generateID(prefix string) string {
	return fmt.Sprintf("%s-%d", prefix, time.Now().UnixNano())
}

func generateSessionToken() (string, error) {
	buf := make([]byte, 32)
	if _, err := rand.Read(buf); err != nil {
		return "", err
	}
	return base64.RawURLEncoding.EncodeToString(buf), nil
}

func randomRoomCode(length int) (string, error) {
	if length <= 0 {
		return "", fmt.Errorf("invalid room code length: %s", strconv.Itoa(length))
	}

	var sb strings.Builder
	sb.Grow(length)
	max := big.NewInt(int64(len(codeCharset)))

	for i := 0; i < length; i++ {
		n, err := rand.Int(rand.Reader, max)
		if err != nil {
			return "", err
		}
		sb.WriteByte(codeCharset[n.Int64()])
	}

	return sb.String(), nil
}
