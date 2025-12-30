extends Action

func enter() -> void:
	character.animation_play("fall")

func exit() -> void:
	character.animation_play("idle")

func tick(_delta: float) -> BTState:
	if character.is_on_floor() and character.velocity.y == 0:
		return BTState.SUCCESS
	return BTState.RUNNING
