extends Action

func tick(_delta: float) -> BTState:
	if character.seek_player():
		return BTState.SUCCESS
	return BTState.FAILURE
