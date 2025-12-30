extends Action

var speed: float = 10

func tick(delta: float) -> BTState:
	character.velocity = Vector2(move_toward(character.velocity.x,
		character.patrol_direction.x * speed,
		speed * delta),
		move_toward(character.velocity.y,
		character.patrol_direction.y * speed,
		speed * delta))
	return BTState.SUCCESS
