local Types = {}

-- Shared Luau type aliases for Stage 1.
-- Runtime rules remain server-authoritative.

export type TeamId = number
export type ProvinceState = {
	Owner: TeamId,
	CaptureTeam: TeamId,
	CaptureProgress: number,
	Income: number,
}

return Types
