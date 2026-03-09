package player

type Service struct{ repo *Repository }

func NewService(repo *Repository) *Service { return &Service{repo: repo} }

func (s *Service) ListByRoomID(roomID string) ([]Player, error) {
	return s.repo.ListByRoomID(roomID)
}
