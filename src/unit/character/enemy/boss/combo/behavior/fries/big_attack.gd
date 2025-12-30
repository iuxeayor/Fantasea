extends Action

const LEFT_EDGE: float = 0
const RIGHT_EDGE: float = 384
const LAND_Y: float = 184
const MIN_VELOCITY_Y: float = -270
const MAX_VELOCITY_Y: float = -300

func enter() -> void:
	character.velocity.x = 0
	var player_x: float = Game.get_player().global_position.x
	# 至少一个对准玩家
	var first_bullet: CharacterBullet = Game.get_object("fry_bullet")
	if first_bullet == null:
		return
	var velocity_y: float = randf_range(MIN_VELOCITY_Y, MAX_VELOCITY_Y)
	var velocity_x: float = Util.calculate_x_velocity_parabola(
			character.shoot_point.global_position,
			Vector2(Game.get_player().global_position.x, LAND_Y),
			velocity_y,
			Constant.gravity)
	first_bullet.spawn(character.shoot_point.global_position, Vector2(velocity_x, velocity_y))
	for _i: int in range(60, 80):
		var bullet: CharacterBullet = Game.get_object("fry_bullet")
		if bullet == null:
			return
		var target_x: float = player_x
		var rand_int: int = randi() % 7
		match rand_int:
			0, 1, 2:
				target_x = randf_range(LEFT_EDGE, player_x - 32)
			3:
				target_x = randf_range(player_x - 4, player_x + 4)
			4, 5, 6:
				target_x = randf_range(player_x + 32, RIGHT_EDGE)
		velocity_y = randf_range(MIN_VELOCITY_Y, MAX_VELOCITY_Y)
		velocity_x = Util.calculate_x_velocity_parabola(
			character.shoot_point.global_position,
			Vector2(target_x, LAND_Y),
			velocity_y,
			Constant.gravity)
		bullet.spawn(character.shoot_point.global_position, Vector2(velocity_x, velocity_y))

func tick(_delta: float) -> BTState:
	return BTState.SUCCESS
