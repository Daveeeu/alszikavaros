package game

import "encoding/json"

func parseNightResult(raw string) (*NightResolution, error) {
	if raw == "" {
		return nil, nil
	}
	var out NightResolution
	if err := json.Unmarshal([]byte(raw), &out); err != nil {
		return nil, err
	}
	return &out, nil
}
