extends Action

func tick(_delta: float) -> BTState:
	if character.moving:
		return BTState.SUCCESS
	return BTState.FAILURE
