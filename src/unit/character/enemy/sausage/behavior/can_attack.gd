extends Action

func tick(_delta: float) -> BTState:
	if (character.attack_checker.is_colliding()
		and character.attack_checker.get_collider() is not TileMapLayer):
		return BTState.SUCCESS
	return BTState.FAILURE
