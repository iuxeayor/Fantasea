extends Action

enum Target {
	PLAYER,
	PLAYER_CLOSE,
	MID,
}

var player_close_offset: float = 24

@export var target: Target = Target.PLAYER
@export var jump_velocity: float = -400
@export var play_animation: bool = false

func enter() -> void:
	super ()
	var target_position: Vector2 = character.global_position
	var player: Player = Game.get_player()
	match target:
		Target.PLAYER:
			target_position = player.global_position
		Target.PLAYER_CLOSE:
			if character.global_position.x < player.global_position.x:
				target_position = player.global_position + Vector2(-player_close_offset, 0)
			elif character.global_position.x > player.global_position.x:
				target_position = player.global_position + Vector2(player_close_offset, 0)
		Target.MID:
				target_position = Vector2(Game.get_game_scene().mid_x, Game.get_game_scene().land_y)
	if play_animation:
		character.animation_play("jump")
	var velocity_x: float = Util.calculate_x_velocity_parabola(character.global_position,
		target_position,
		jump_velocity,
		Constant.gravity)
	character.velocity = Vector2(velocity_x, jump_velocity)


func tick(_delta: float) -> BTState:
	if character.velocity.y >= 0:
		return BTState.SUCCESS
	return BTState.RUNNING
