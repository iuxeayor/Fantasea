extends Action

const TOP_Y: float = 48
const MID_Y: float = 128
const BOTTOM_Y: float = 184
const MAX_DISTANCE: float = 192

const LOW_JUMP_VELOCITY: float = -360
const HIGH_JUMP_VELOCITY: float = -510

enum Target {
	PLAYER,
	PLAYER_TOP,
	RADOM
}

@export var target: Target = Target.PLAYER

func enter() -> void:
	var target_position: Vector2 = character.global_position
	var player: Player = Game.get_player()
	match target:
		Target.PLAYER:
			if player.global_position.y < MID_Y:
				target_position = Vector2(player.global_position.x, TOP_Y)
			else:
				target_position = Vector2(player.global_position.x, BOTTOM_Y)
		Target.PLAYER_TOP:
			target_position = Vector2(player.global_position.x, TOP_Y)
		Target.RADOM:
			target_position = Vector2(
				player.global_position.x,
				randf_range(TOP_Y, max(player.global_position.y, TOP_Y)))
	if target_position.y > 128:
		var velocity_x: float = Util.calculate_x_velocity_parabola(character.global_position,
		target_position,
		LOW_JUMP_VELOCITY,
		Constant.gravity,
		MAX_DISTANCE)
		character.velocity = Vector2(velocity_x, LOW_JUMP_VELOCITY)
	else:
		var velocity_x: float = Util.calculate_x_velocity_parabola(character.global_position,
		target_position,
		HIGH_JUMP_VELOCITY,
		Constant.gravity,
		MAX_DISTANCE)
		character.velocity = Vector2(velocity_x, HIGH_JUMP_VELOCITY)
	character.animation_play("jump")
	SoundManager.play_sfx("BurgerJump")

func tick(_delta: float) -> BTState:
	if character.velocity.y >= 0:
		return BTState.SUCCESS
	return BTState.RUNNING
