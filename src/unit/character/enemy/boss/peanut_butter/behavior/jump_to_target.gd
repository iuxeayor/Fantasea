extends Action

enum Target {
	PLAYER,
	PLAYER_FRONT,
	FAR_FROM_PLAYER,
	LEFT,
	RIGHT,
	MID,
}

var jump_velocity_normal: float = -240
var jump_velocity_cross_player: float = -380
var player_offset: float = 24

@export var target: Target = Target.PLAYER

var desire_velo: Vector2 = Vector2.ZERO
var should_jump: bool = false

func enter() -> void:
	super ()
	var target_position: Vector2 = character.global_position
	var player: Player = Game.get_player()
	match target:
		Target.PLAYER:
			if character.global_position.x < player.global_position.x:
				target_position = Vector2(player.global_position.x - player_offset,
					Game.get_game_scene().land_y)
			else:
				target_position = Vector2(player.global_position.x + player_offset,
					Game.get_game_scene().land_y)
		Target.PLAYER_FRONT:
			target_position = Vector2(
				clampf(player.global_position.x + player.face_direction * player_offset,
					Game.get_game_scene().left_edge,
					Game.get_game_scene().right_edge),
				Game.get_game_scene().land_y)
		Target.FAR_FROM_PLAYER:
			# 基于玩家的位置，到左右两侧的最远距离
			if Game.get_player().global_position.x < Game.get_game_scene().mid_point.global_position.x:
				target_position = Game.get_game_scene().right_point.global_position
			else:
				target_position = Game.get_game_scene().left_point.global_position
		Target.LEFT:
			target_position = Game.get_game_scene().left_point.global_position
		Target.RIGHT:
			target_position = Game.get_game_scene().right_point.global_position
		Target.MID:
			target_position = Game.get_game_scene().mid_point.global_position
	target_position.x = clampf(target_position.x,
		Game.get_game_scene().left_edge,
		Game.get_game_scene().right_edge)
	if target_position.distance_to(character.global_position) < 8:
		return
	should_jump = true
	var target_jump_velocity: float = jump_velocity_normal
	if (character.global_position.x - player.global_position.x) * (target_position.x - player.global_position.x) < 0:
		target_jump_velocity = jump_velocity_cross_player
	character.animation_play("charge_jump")
	var velocity_x: float = Util.calculate_x_velocity_parabola(character.global_position,
		target_position,
		target_jump_velocity,
		Constant.gravity)
	desire_velo = Vector2(velocity_x, target_jump_velocity)

func exit() -> void:
	super ()
	character.animation_play("fall")
	desire_velo = Vector2.ZERO
	should_jump = false


func tick(_delta: float) -> BTState:
	if not should_jump:
		return BTState.SUCCESS
	if character.animation_player.is_playing():
		if character.animation_player.current_animation == "charge_jump":
			return BTState.RUNNING
		elif character.animation_player.current_animation == "jump":
			if character.velocity.y >= 0:
				return BTState.SUCCESS
			return BTState.RUNNING
	else:
		character.animation_play("jump")
		character.velocity = desire_velo
	return BTState.RUNNING
