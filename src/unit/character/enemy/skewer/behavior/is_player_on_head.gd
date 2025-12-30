extends Action

func tick(_delta: float) -> BTState:
	if (character.top_player_checker.is_colliding()
		and character.top_player_checker.get_collider() is Player):
		return BTState.SUCCESS
	return BTState.FAILURE
