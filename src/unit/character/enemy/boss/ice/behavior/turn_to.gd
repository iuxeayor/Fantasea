extends Action

enum Target {
	PLAYER,
	RANDOM,
	INVERT,
	PLAYER_INVERT,
}

@export var target: Target = Target.PLAYER

func enter() -> void:
	super ()
	match target:
		Target.PLAYER:
			if Game.get_player().global_position.x < character.global_position.x:
				character.direction = Constant.Direction.LEFT
			elif Game.get_player().global_position.x > character.global_position.x:
				character.direction = Constant.Direction.RIGHT
		Target.RANDOM:
			if randi() % 2 == 0:
				character.direction = Constant.Direction.LEFT
			else:
				character.direction = Constant.Direction.RIGHT
		Target.INVERT:
			character.direction = - character.direction
		Target.PLAYER_INVERT:
			if Game.get_player().global_position.x < character.global_position.x:
				character.direction = Constant.Direction.RIGHT
			elif Game.get_player().global_position.x > character.global_position.x:
				character.direction = Constant.Direction.LEFT
	

func tick(_delta: float) -> BTState:
	return BTState.SUCCESS
