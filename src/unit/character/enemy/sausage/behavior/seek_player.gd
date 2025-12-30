extends Action

func tick(_delta: float) -> BTState:
	if (character.seek_checker.is_colliding()
		and character.seek_checker.get_collider() is not TileMapLayer):
		return BTState.SUCCESS
	return BTState.FAILURE
