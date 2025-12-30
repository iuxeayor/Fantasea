extends Action

func tick(_delta: float) -> BTState:
	return BTState.SUCCESS if character.resurrecting else BTState.FAILURE
