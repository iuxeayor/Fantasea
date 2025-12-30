extends Action

enum Target {
	PLAYER,
	PLAYER_INVERSE,
	MID,
}

@export var target: Target = Target.PLAYER ## 面向目标

func enter() -> void:
	super ()
	var player_pos_x: float = Game.get_player().global_position.x
	match target:
		Target.PLAYER:
			if character.global_position.x < player_pos_x:
				character.direction = Constant.Direction.RIGHT
			elif character.global_position.x > player_pos_x:
				character.direction = Constant.Direction.LEFT
		Target.PLAYER_INVERSE:
			if character.global_position.x < player_pos_x:
				character.direction = Constant.Direction.LEFT
			elif character.global_position.x > player_pos_x:
				character.direction = Constant.Direction.RIGHT
		Target.MID:
			if character.global_position.x < Game.get_game_scene().MID_X:
				character.direction = Constant.Direction.RIGHT
			elif character.global_position.x > Game.get_game_scene().MID_X:
				character.direction = Constant.Direction.LEFT
	

func tick(_delta: float) -> BTState:
	return BTState.SUCCESS
