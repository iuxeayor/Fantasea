extends Action

func enter() -> void:
	var player_pos_x: float = Game.get_player().global_position.x
	if character.global_position.x < player_pos_x:
		character.direction = Constant.Direction.RIGHT
	elif character.global_position.x > player_pos_x:
		character.direction = Constant.Direction.LEFT

func tick(_delta: float) -> BTState:
	return BTState.SUCCESS
