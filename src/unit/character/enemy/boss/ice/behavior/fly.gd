extends Action

@export var jump_velocity: float = -40

func enter() -> void:
	super ()
	character.animation_play("jump")
	character.gravity = 0
	character.velocity.y = jump_velocity

func tick(_delta: float) -> BTState:
	return BTState.SUCCESS
