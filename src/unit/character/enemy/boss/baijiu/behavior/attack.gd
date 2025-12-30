extends Action

const PLATFORM_X: Array[float] = [48, 144, 240, 336]
const PLATFORM_Y: float = 176
const MIN_VELOCITY_Y: float = -400
const MAX_VELOCITY_Y: float = -460

enum Target {
	PLAYER,
	PLAYER_PLATFORM,
	RANDOM_PLATFORM,
	MID_PLATFORM,
}

@export var target: Target = Target.PLAYER

func enter() -> void:
	var alcohol_bullet: CharacterBullet = Game.get_object("alcohol_bullet")
	if alcohol_bullet == null:
		return
	var target_x: float = Game.get_player().global_position.x
	match target:
		Target.PLAYER:
			target_x = Game.get_player().global_position.x + Game.get_player().face_direction * 8
		Target.PLAYER_PLATFORM:
			var player_x: float = Game.get_player().global_position.x
			var closest_index: int = 0
			var closest_distance: float = abs(PLATFORM_X[0] - player_x)
			for i: int in PLATFORM_X.size():
				var distance: float = abs(PLATFORM_X[i] - player_x)
				if distance < closest_distance:
					closest_distance = distance
					closest_index = i
			target_x = PLATFORM_X[closest_index]
			target_x += randf_range(-32, 32)
		Target.RANDOM_PLATFORM:
			var new_index: int = randi_range(0, 3)
			if new_index == character.current_platform_index:
				# 排除当前平台
				match new_index:
					0:
						new_index = 3
					3:
						new_index = 0
					_:
						if randi() % 2 == 0:
							new_index -= 1
						else:
							new_index += 1
			target_x = PLATFORM_X[new_index] + randf_range(-32, 32)
		Target.MID_PLATFORM:
			match randi() % 6:
				0, 1:
					target_x = PLATFORM_X[1] + randf_range(-32, 32)
				2, 3:
					target_x = PLATFORM_X[2] + randf_range(-32, 32)
				4:
					target_x = PLATFORM_X[0] + 16 + randf_range(-16, 16)
				5:
					target_x = PLATFORM_X[3] - 16 + randf_range(-16, 16)
			
	var target_position: Vector2 = Vector2(target_x, PLATFORM_Y)
	var start_position: Vector2 = character.attack_point.global_position
	var velocity_y: float = randf_range(MAX_VELOCITY_Y, MIN_VELOCITY_Y)
	var velocity_x: float = Util.calculate_x_velocity_parabola(
		start_position,
		target_position,
		velocity_y,
		900)
	alcohol_bullet.spawn(start_position, Vector2(velocity_x, velocity_y))
	if target == Target.MID_PLATFORM: # 转阶段时减少时间
		alcohol_bullet.life_timer.start(randf_range(0.5, 1.5))
	else:
		alcohol_bullet.life_timer.start(5)
	if target_x < character.global_position.x:
		character.direction = Constant.Direction.LEFT
	else:
		character.direction = Constant.Direction.RIGHT


func tick(_delta: float) -> BTState:
	return BTState.SUCCESS
