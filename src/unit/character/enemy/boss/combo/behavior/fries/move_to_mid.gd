extends Action

const LEFT_RANGE: float = 128
const RIGHT_RANGE: float = 256
const SPEED: float = 90

var target_x: float = 0.0

func enter() -> void:
	character.animation_play("walk", true)
	target_x = randf_range(LEFT_RANGE, RIGHT_RANGE)
	if character.global_position.x < target_x:
		character.direction = Constant.Direction.RIGHT
	else:
		character.direction = Constant.Direction.LEFT
	
	

func exit() -> void:
	character.animation_play("idle")
	character.velocity.x = 0

func tick(delta: float) -> BTState:
	character.velocity.x = move_toward(
		character.velocity.x,
		character.direction * SPEED,
		SPEED * 2 * delta)
	if character.direction == Constant.Direction.LEFT:
		if character.global_position.x <= target_x:
			return BTState.SUCCESS
	else:
		if character.global_position.x >= target_x:
			return BTState.SUCCESS
	return BTState.RUNNING
