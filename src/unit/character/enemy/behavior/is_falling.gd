extends Action

func tick(_delta: float) -> BTState:
	if character.falling:
		return BTState.SUCCESS
	return BTState.FAILURE
