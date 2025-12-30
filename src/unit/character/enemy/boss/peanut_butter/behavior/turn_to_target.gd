extends Action

enum Target {
	PLAYER,
	PLAYER_FAR,
	MID,
	LEFT,
	RIGHT
}

@export var target: Target = Target.PLAYER

func enter() -> void:
	super ()
	match target:
		Target.PLAYER:
			if Game.get_player().global_position.x > character.global_position.x:
				character.direction = Constant.Direction.RIGHT
			elif Game.get_player().global_position.x < character.global_position.x:
				character.direction = Constant.Direction.LEFT
		Target.PLAYER_FAR:
			if Game.get_player().global_position.x > character.global_position.x:
				character.direction = Constant.Direction.LEFT
			elif Game.get_player().global_position.x < character.global_position.x:
				character.direction = Constant.Direction.RIGHT
		Target.MID:
			if Game.get_game_scene().mid_point.global_position.x > character.global_position.x:
				character.direction = Constant.Direction.RIGHT
			elif Game.get_game_scene().mid_point.global_position.x < character.global_position.x:
				character.direction = Constant.Direction.LEFT
		Target.LEFT:
			if Game.get_game_scene().left_point.global_position.x > character.global_position.x:
				character.direction = Constant.Direction.RIGHT
			elif Game.get_game_scene().left_point.global_position.x < character.global_position.x:
				character.direction = Constant.Direction.LEFT
		Target.RIGHT:
			if Game.get_game_scene().right_point.global_position.x > character.global_position.x:
				character.direction = Constant.Direction.RIGHT
			elif Game.get_game_scene().right_point.global_position.x < character.global_position.x:
				character.direction = Constant.Direction.LEFT

func tick(_delta: float) -> BTState:
	return BTState.SUCCESS
