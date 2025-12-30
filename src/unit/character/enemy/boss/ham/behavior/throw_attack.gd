extends Action

const LEFT_X: float = 56
const RIGHT_X: float = 328
const MID_X: float = (LEFT_X + RIGHT_X) / 2
const LAND_Y: float = 176
const VELOCITY_Y: float = -420

func enter() -> void:
	var player_x: float = Game.get_player().global_position.x
	if player_x < character.global_position.x:
		character.direction = Constant.Direction.LEFT
	else:
		character.direction = Constant.Direction.RIGHT
	_shoot_bullet(Vector2(player_x, LAND_Y))
	match character.battle_stage:
		1:
			if player_x < MID_X:
				_shoot_bullet(Vector2(randf_range(RIGHT_X, MID_X + 32), LAND_Y))
			else:
				_shoot_bullet(Vector2(randf_range(LEFT_X, MID_X - 32), LAND_Y))
		2:
			if player_x < MID_X:
				_shoot_bullet(Vector2(randf_range(RIGHT_X, MID_X + 32), LAND_Y))
			else:
				_shoot_bullet(Vector2(randf_range(LEFT_X, MID_X - 32), LAND_Y))
			if randi() % 2 == 0:
				_shoot_skewer(Vector2(LEFT_X, LAND_Y))
			else:
				_shoot_skewer(Vector2(RIGHT_X, LAND_Y))
			

func tick(_delta: float) -> BTState:
	return BTState.SUCCESS


func _shoot_bullet(target_pos: Vector2) -> void:
	var charcoal_bullet: CharacterBullet = Game.get_object("charcoal_bullet")
	if charcoal_bullet == null:
		return
	var velocity_x: float = Util.calculate_x_velocity_parabola(
		character.throw_point.global_position,
		target_pos,
		VELOCITY_Y,
		Constant.gravity
	)
	charcoal_bullet.spawn(
		character.throw_point.global_position,
		Vector2(velocity_x, VELOCITY_Y)
	)

func _shoot_skewer(target_pos: Vector2) -> void:
	var skewer: Enemy = character.SKEWER.instantiate()
	if skewer == null:
		return
	var velocity_x: float = Util.calculate_x_velocity_parabola(
		character.throw_point.global_position,
		target_pos,
		VELOCITY_Y,
		Constant.gravity
	)
	Game.get_game_scene().object_pool.add_child(skewer)
	skewer.global_position = character.throw_point.global_position
	if target_pos.x < MID_X:
		skewer.direction = Constant.Direction.RIGHT
	else:
		skewer.direction = Constant.Direction.LEFT
	skewer.velocity = Vector2(velocity_x, VELOCITY_Y)
