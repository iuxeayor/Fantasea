extends Action

func enter() -> void:
	super()
	if character.velocity.x > 0:
		character.direction = Constant.Direction.RIGHT
	elif character.velocity.x < 0:
		character.direction = Constant.Direction.LEFT

func tick(_delta: float) -> BTState:
	return BTState.SUCCESS
