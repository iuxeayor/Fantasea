extends Action

func tick(_delta: float) -> BTState:
	if not character.hurt_timer.is_stopped():
		if character.is_on_floor() and character.velocity.y >= 0:
			return BTState.SUCCESS
		return BTState.FAILURE
	return BTState.SUCCESS
