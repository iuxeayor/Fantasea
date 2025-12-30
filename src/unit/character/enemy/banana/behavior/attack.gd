extends Action

const Y_VELOCITY: float = -400

func exit() -> void:
	var bullet: CharacterBullet = Game.get_object("banana_bullet")
	if bullet == null:
		return
	var speed: float = Util.calculate_x_velocity_parabola(character.global_position,
		Game.get_player().global_position,
		Y_VELOCITY,
		bullet.gravity)
	bullet.spawn(character.global_position, Vector2(speed, Y_VELOCITY))


func tick(_delta: float) -> BTState:
	return BTState.SUCCESS
