extends Action

@export var fall_anim: bool = false

func enter() -> void:
	if fall_anim:
		character.animation_play("fall")

func tick(_delta: float) -> BTState:
	if character.is_on_floor() and character.velocity.y == 0:
		return BTState.SUCCESS
	return BTState.RUNNING
