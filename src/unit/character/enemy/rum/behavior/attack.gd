extends Action

func enter() -> void:
	var can_rum_bullet: RigidBullet = Game.get_object("can_rum_bullet")
	if can_rum_bullet == null:
		return
	var y_velocity: float = randf_range(-180, -240)
	var x_velocity: float = Util.calculate_x_velocity_parabola(
		character.attack_point.global_position,
		Vector2(
			Game.get_player().global_position.x,
			character.global_position.y
		),
		y_velocity,
		Constant.gravity
	)
	can_rum_bullet.spawn(character.attack_point.global_position, Vector2(x_velocity, y_velocity))

func tick(_delta: float) -> BTState:
	return BTState.SUCCESS
