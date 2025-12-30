extends Action

enum Target {
	PLAYER,
	PLAYER_CLOSE,
	PLAYER_INVERT,
	INVERT,
	RANDOM,
	MID,
	MID_INVERT,
}

var player_close_offset: float = 24

@export var target: Target = Target.PLAYER

func enter() -> void:
	super ()
	var player: Player = Game.get_player()
	match target:
		Target.PLAYER:
			if character.global_position.x < player.global_position.x:
				character.direction = Constant.Direction.RIGHT
			elif character.global_position.x > player.global_position.x:
				character.direction = Constant.Direction.LEFT
		Target.PLAYER_CLOSE:
			var target_x: float = character.global_position.x
			if character.global_position.x < player.global_position.x:
				target_x = player.global_position.x - player_close_offset
			elif character.global_position.x > player.global_position.x:
				target_x = player.global_position.x + player_close_offset
			if character.global_position.x < target_x:
				character.direction = Constant.Direction.RIGHT
			elif character.global_position.x > target_x:
				character.direction = Constant.Direction.LEFT
		Target.PLAYER_INVERT:
			if character.global_position.x < player.global_position.x:
				character.direction = Constant.Direction.LEFT
			elif character.global_position.x > player.global_position.x:
				character.direction = Constant.Direction.RIGHT
		Target.INVERT:
			character.direction = - character.direction
		Target.RANDOM:
			character.direction = Constant.Direction.LEFT if randi() % 2 == 0 else Constant.Direction.RIGHT
		Target.MID:
			if character.global_position.x < Game.get_game_scene().mid_x:
				character.direction = Constant.Direction.RIGHT
			elif character.global_position.x > Game.get_game_scene().mid_x:
				character.direction = Constant.Direction.LEFT
		Target.MID_INVERT:
			if character.global_position.x < Game.get_game_scene().mid_x:
				character.direction = Constant.Direction.LEFT
			elif character.global_position.x > Game.get_game_scene().mid_x:
				character.direction = Constant.Direction.RIGHT

func tick(_delta: float) -> BTState:
	return BTState.SUCCESS
