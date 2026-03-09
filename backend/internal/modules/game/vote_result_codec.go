package game

import "encoding/json"

func parseVoteResult(raw string) (*VoteResolution, error) {
	if raw == "" {
		return nil, nil
	}
	var out VoteResolution
	if err := json.Unmarshal([]byte(raw), &out); err != nil {
		return nil, err
	}
	return &out, nil
}
