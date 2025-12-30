extends Action

func tick(_delta: float) -> BTState:
	if Game.get_player() != null and Game.get_player().global_position.distance_to(character.global_position) < 24:
		return BTState.SUCCESS
	return BTState.FAILURE
