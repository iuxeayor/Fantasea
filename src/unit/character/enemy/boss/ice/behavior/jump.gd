extends Action

@export var jump_velocity: float = -40

func enter() -> void:
	super ()
	character.animation_play("jump")
	character.velocity.y = jump_velocity

func tick(_delta: float) -> BTState:
	if character.velocity.y >= 0:
		return BTState.SUCCESS
	return BTState.RUNNING
