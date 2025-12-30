extends Action

func tick(_delta: float) -> BTState:
	if (character.player_checker.has_overlapping_bodies()
		and character.attack_cool_down_timer.is_stopped()):
		return BTState.SUCCESS
	return BTState.FAILURE
