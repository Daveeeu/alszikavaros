package shared

import "strings"

func RequireNonEmptyTrimmed(value string, field string) *APIError {
	if strings.TrimSpace(value) != "" {
		return nil
	}
	return InvalidRequest("invalid request payload", map[string]any{
		"field": field,
		"rule":  "required",
	})
}

func RequireMinLength(value string, field string, min int) *APIError {
	if len(strings.TrimSpace(value)) >= min {
		return nil
	}
	return InvalidRequest("invalid request payload", map[string]any{
		"field": field,
		"rule":  "min_length",
		"min":   min,
	})
}
