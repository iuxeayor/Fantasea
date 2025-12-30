extends Action

func tick(_delta: float) -> BTState:
	if character.player_checker.has_overlapping_bodies():
		return BTState.SUCCESS
	return BTState.FAILURE
