extends Action

func tick(_delta: float) -> BTState:
	if ((character.player_checker.is_colliding()
		or character.seed_checker.has_overlapping_bodies())
		and character.hurt_timer.is_stopped()):
		return BTState.SUCCESS
	return BTState.FAILURE
