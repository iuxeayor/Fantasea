extends Action

func tick(_delta: float) -> BTState:
	if character.wall_checker.is_colliding():
		character.direction = - character.direction
	return BTState.SUCCESS
