extends Action

const JUMP_VELOCITY: float = -400.0

func enter() -> void:
	character.animation_play("transform_back")
	var target_position: Vector2 = character.global_position
	var player: Player = Game.get_player()
	if player != null:
		target_position = player.global_position
	var velocity_x: float = Util.calculate_x_velocity_parabola(character.global_position,
		target_position,
		JUMP_VELOCITY,
		Constant.gravity,
		320)
	character.velocity = Vector2(velocity_x, JUMP_VELOCITY)

func exit() -> void:
	character.velocity.x = 0

func tick(_delta: float) -> BTState:
	if character.is_on_floor() and character.velocity.y == 0:
		return BTState.SUCCESS
	return BTState.RUNNING
