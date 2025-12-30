extends Action

var speed: float = 40

func tick(delta: float) -> BTState:
	var direction: Vector2 = character.global_position.direction_to(character.target_position)
	character.velocity = Vector2(
		move_toward(character.velocity.x,
		direction.x * speed,
		speed * 2 * delta),
		move_toward(character.velocity.y,
		direction.y * speed,
		speed * 2 * delta))
	character.patrol_position = character.global_position
	return BTState.FAILURE
