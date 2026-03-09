package shared

import (
	"encoding/json"
	"net/http"
)

type APIResponse struct {
	Success bool        `json:"success"`
	Data    interface{} `json:"data,omitempty"`
	Error   *APIError   `json:"error,omitempty"`
}

func OK(w http.ResponseWriter, _ *http.Request, data interface{}) {
	writeJSON(w, http.StatusOK, APIResponse{Success: true, Data: data})
}

func Created(w http.ResponseWriter, _ *http.Request, data interface{}) {
	writeJSON(w, http.StatusCreated, APIResponse{Success: true, Data: data})
}

func Fail(w http.ResponseWriter, _ *http.Request, status int, message string) {
	writeJSON(w, status, APIResponse{
		Success: false,
		Error:   NewAPIError(status, ErrCodeInvalidRequest, message, nil),
	})
}

func FailError(w http.ResponseWriter, _ *http.Request, apiErr *APIError) {
	if apiErr == nil {
		apiErr = Internal("internal server error")
	}
	if apiErr.Status == 0 {
		apiErr.Status = http.StatusInternalServerError
	}
	writeJSON(w, apiErr.Status, APIResponse{Success: false, Error: apiErr})
}

func DecodeJSON(r *http.Request, target interface{}) error {
	defer r.Body.Close()
	decoder := json.NewDecoder(r.Body)
	decoder.DisallowUnknownFields()
	return decoder.Decode(target)
}

func writeJSON(w http.ResponseWriter, status int, payload interface{}) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(payload)
}
