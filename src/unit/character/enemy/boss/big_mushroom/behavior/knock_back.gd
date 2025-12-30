extends Action

func enter() -> void:
	character.animation_play("stun")
	character.velocity.x = -character.direction * 120
	character.velocity.y = -240

func tick(_delta: float) -> BTState:
	if character.is_on_floor() and character.velocity.y == 0:
		return BTState.SUCCESS
	return BTState.RUNNING
