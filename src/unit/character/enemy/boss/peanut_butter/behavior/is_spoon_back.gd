extends Action

func tick(_delta: float) -> BTState:
	if Game.get_game_scene().spoon_bullet.is_idle():
		return BTState.SUCCESS
	return BTState.FAILURE
