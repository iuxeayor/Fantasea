extends Action

func tick(_delta: float) -> BTState:
	return BTState.FAILURE if character.status.health <= 0 else BTState.SUCCESS
