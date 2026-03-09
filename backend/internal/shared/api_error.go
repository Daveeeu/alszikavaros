package shared

import (
	"errors"
	"net/http"
	"time"
)

type ErrorCode string

const (
	ErrCodeInvalidRequest ErrorCode = "invalid_request"
	ErrCodeUnauthorized   ErrorCode = "unauthorized"
	ErrCodeForbidden      ErrorCode = "forbidden"
	ErrCodeNotFound       ErrorCode = "not_found"
	ErrCodeConflict       ErrorCode = "conflict"
	ErrCodeInvalidPhase   ErrorCode = "invalid_phase"
	ErrCodeInvalidAction  ErrorCode = "invalid_action"
	ErrCodeInternal       ErrorCode = "internal_error"
)

type APIError struct {
	Code       ErrorCode      `json:"code"`
	Message    string         `json:"message"`
	Status     int            `json:"-"`
	Details    map[string]any `json:"details,omitempty"`
	OccurredAt time.Time      `json:"occurredAt"`
}

func (e *APIError) Error() string {
	if e == nil {
		return ""
	}
	return e.Message
}

func NewAPIError(status int, code ErrorCode, message string, details map[string]any) *APIError {
	return &APIError{
		Code:       code,
		Message:    message,
		Status:     status,
		Details:    details,
		OccurredAt: time.Now().UTC(),
	}
}

func Unauthorized(message string) *APIError {
	return NewAPIError(http.StatusUnauthorized, ErrCodeUnauthorized, message, nil)
}

func Forbidden(message string) *APIError {
	return NewAPIError(http.StatusForbidden, ErrCodeForbidden, message, nil)
}

func NotFound(message string) *APIError {
	return NewAPIError(http.StatusNotFound, ErrCodeNotFound, message, nil)
}

func Conflict(message string) *APIError {
	return NewAPIError(http.StatusConflict, ErrCodeConflict, message, nil)
}

func InvalidRequest(message string, details map[string]any) *APIError {
	return NewAPIError(http.StatusBadRequest, ErrCodeInvalidRequest, message, details)
}

func InvalidPhase(message string) *APIError {
	return NewAPIError(http.StatusConflict, ErrCodeInvalidPhase, message, nil)
}

func InvalidAction(message string) *APIError {
	return NewAPIError(http.StatusBadRequest, ErrCodeInvalidAction, message, nil)
}

func Internal(message string) *APIError {
	return NewAPIError(http.StatusInternalServerError, ErrCodeInternal, message, nil)
}

func AsAPIError(err error) (*APIError, bool) {
	var apiErr *APIError
	if errors.As(err, &apiErr) {
		return apiErr, true
	}
	return nil, false
}
