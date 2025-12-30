extends Action

func tick(_delta: float) -> BTState:
	if (character.player_see_checker.is_colliding()
		and character.player_see_checker.get_collider() is Player
		and character.player_checker.has_overlapping_bodies()):
		return BTState.SUCCESS
	return BTState.FAILURE
