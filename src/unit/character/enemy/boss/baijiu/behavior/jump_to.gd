extends Action

const STAND_POINT_X: Array[float] = [48, 144, 240, 336]
const STAND_Y: float = 176
const EDGE_LEFT_X: float = 24
const EDGE_RIGHT_X: float = 360

const LOW_JUMP_VELOCITY: float = -240
const HIGH_JUMP_VELOCITY: float = -460

enum Target {
	RANDOM,
	FRONT,
	BACK,
	FAR_EDGE,
}

@export var target: Target = Target.RANDOM

var target_index: int = 0

func enter() -> void:
	var current_index: int = character.current_platform_index
	match target:
		Target.RANDOM:
			var new_index: int = randi_range(0, 3)
			if new_index == current_index:
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
			target_index = new_index
		Target.FRONT:
			var new_index: int = 0
			if character.direction == Constant.Direction.LEFT:
				if current_index == 0:
					if Game.get_player().global_position.x < character.global_position.x:
						new_index = 2
					else:
						new_index = 1
				else:
					new_index = current_index - 1
			else:
				if current_index == 3:
					if Game.get_player().global_position.x > character.global_position.x:
						new_index = 1
					else:
						new_index = 2
				else:
					new_index = current_index + 1
			target_index = new_index
		Target.BACK:
			var new_index: int = 0
			if character.direction == Constant.Direction.LEFT:
				if current_index == 3:
					if Game.get_player().global_position.x < character.global_position.x:
						new_index = 1
					else:	
						new_index = 2
				else:
					new_index = current_index + 1
			else:
				if current_index == 0:
					if Game.get_player().global_position.x > character.global_position.x:
						new_index = 2
					else:
						new_index = 1
				else:
					new_index = current_index - 1
			target_index = new_index
	var target_pos: Vector2 = Vector2(STAND_POINT_X[target_index] + randf_range(8, -8), STAND_Y)
	if target == Target.FAR_EDGE:
		if character.current_platform_index <= 1:
			target_pos.x = EDGE_RIGHT_X
		else:
			target_pos.x = EDGE_LEFT_X
	var player_x: float = Game.get_player().global_position.x
	var player_between : bool = (player_x
		>= min(character.global_position.x, target_pos.x) 
		and player_x <= max(character.global_position.x, target_pos.x))
	var velocity_y: float = HIGH_JUMP_VELOCITY
	if player_between:
		velocity_y = HIGH_JUMP_VELOCITY
	else:
		velocity_y = LOW_JUMP_VELOCITY
	var velocity_x: float = Util.calculate_x_velocity_parabola(
		character.global_position,
		target_pos,
		velocity_y,
		Constant.gravity
	)
	character.velocity = Vector2(velocity_x, velocity_y)
	character.animation_play("jump")
	SoundManager.play_sfx("BaijiuJump")

func exit() -> void:
	character.current_platform_index = target_index

func tick(_delta: float) -> BTState:
	if character.velocity.y >= 0:
		return BTState.SUCCESS
	return BTState.RUNNING
