extends Action

func tick(_delta: float) -> BTState:
	if character.attacking:
		return BTState.SUCCESS
	return BTState.FAILURE
