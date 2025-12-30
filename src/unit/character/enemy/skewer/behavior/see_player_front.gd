extends Action

func tick(_delta: float) -> BTState:
	if (character.front_player_checker.is_colliding()
		and character.front_player_checker.get_collider() is Player):
		return BTState.SUCCESS
	return BTState.FAILURE
