package action

import "github.com/Daveeeu/alszikavaros/backend/internal/shared"

type TargetingRules struct {
	AllowKillerSelfTarget bool
	AllowDoctorSelfTarget bool
}

func DefaultTargetingRules() TargetingRules {
	return TargetingRules{
		AllowKillerSelfTarget: false,
		AllowDoctorSelfTarget: true,
	}
}

func (r TargetingRules) AllowsSelfTarget(role shared.Role) bool {
	switch role {
	case shared.RoleKiller:
		return r.AllowKillerSelfTarget
	case shared.RoleDoctor:
		return r.AllowDoctorSelfTarget
	default:
		return false
	}
}
