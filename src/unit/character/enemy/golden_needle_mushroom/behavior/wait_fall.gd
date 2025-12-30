extends Action

func tick(_delta: float) -> BTState:
	if character.is_on_floor() and character.velocity.y == 0:
		return BTState.SUCCESS
	return BTState.RUNNING
