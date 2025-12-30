extends Action

const BOTTOM_JUMP_VELOCITY: float = -460
const TOP_JUMP_VELOCITY: float = -240
const MID_Y: float = 128

const TARGET: Vector2 = Vector2(192, 80)

func enter() -> void:
	if (character.global_position - TARGET).length() < 8:
		return
	character.animation_play("jump")
	if character.global_position.x < TARGET.x:
		character.direction = Constant.Direction.RIGHT
	else:
		character.direction = Constant.Direction.LEFT
	var jump_velocity: float = BOTTOM_JUMP_VELOCITY
	if character.global_position.y < MID_Y:
		jump_velocity = TOP_JUMP_VELOCITY
	var velocity_x: float = Util.calculate_x_velocity_parabola(character.global_position,
		TARGET,
		jump_velocity,
		Constant.gravity)
	character.velocity = Vector2(velocity_x, jump_velocity)

func tick(_delta: float) -> BTState:
	if character.velocity.y >= 0:
		return BTState.SUCCESS
	return BTState.RUNNING
