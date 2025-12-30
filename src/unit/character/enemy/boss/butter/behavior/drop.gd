extends Action

@export var speed: float = 360

func enter() -> void:
	super ()
	character.velocity.x = 0
	character.velocity.y = speed
	character.gravity = Constant.gravity

func tick(_delta: float) -> BTState:
	if character.is_on_floor() and character.velocity.y == 0:
		return BTState.SUCCESS
	return BTState.RUNNING
