extends Action

const X_SPEED: float = 100
const Y_SPEED: float = 220

func exit() -> void:
	# 向左射出
	for i: int in range(randi_range(3, 5)):
		var bullet: RigidBullet = Game.get_object("popcorn_bullet")
		if bullet == null:
			break
		bullet.spawn(
			character.shoot_point.global_position,
			Vector2(randf_range(-1, 0) * X_SPEED, randf_range(-1, -0.5) * Y_SPEED)
		)
	# 向右射出
	for i: int in range(randi_range(3, 5)):
		var bullet: RigidBullet = Game.get_object("popcorn_bullet")
		if bullet == null:
			break
		bullet.spawn(
			character.shoot_point.global_position,
			Vector2(randf_range(0.1, 1) * X_SPEED, randf_range(-1, -0.5) * Y_SPEED)
		)
	character.attack_cool_down_timer.start()
	character.patrol_timer.start(2)
	character.moving = true

func tick(_delta: float) -> BTState:
	return BTState.SUCCESS
