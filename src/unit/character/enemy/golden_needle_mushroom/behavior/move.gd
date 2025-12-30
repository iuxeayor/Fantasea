extends Action

func enter() -> void:
	character.animation_play("walk")

func tick(delta: float) -> BTState:
	if character.is_on_floor():
		character.velocity.x = move_toward(character.velocity.x,
			character.direction * character.speed,
			(character.knockback_speed + character.speed) * 6 * delta)
	return BTState.SUCCESS
