extends Action

enum Target {
	PLAYER,
	ORIGIN_EDGE,
}

var player_offset: float = 24
@export var target: Target = Target.PLAYER
var jump_velocity: float = -470


func enter() -> void:
	super ()
	var sky_y: float = Game.get_game_scene().sky_y
	var target_position: Vector2 = Vector2(character.global_position.x, sky_y)
	var player: Player = Game.get_player()
	match target:
		Target.PLAYER:
			target_position = Vector2(player.global_position.x, Game.get_game_scene().sky_y)
		Target.ORIGIN_EDGE:
			if character.global_position.x < Game.get_game_scene().mid_x:
				target_position = Vector2(Game.get_game_scene().left_x, sky_y)
			else:
				target_position = Vector2(Game.get_game_scene().right_x, sky_y)
	target_position.x = clampf(target_position.x,
		Game.get_game_scene().left_x,
		Game.get_game_scene().right_x)
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
