extends Action

var distance: float = 8

func tick(_delta: float) -> BTState:
	if character.global_position.distance_to(character.target_position) < distance:
		return BTState.SUCCESS
	return BTState.FAILURE
