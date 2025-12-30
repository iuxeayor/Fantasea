extends Action

enum Target {
	RANDOM,
	PLAYER,
	PLAYER_INVERT,
	TURN
}

@export var target: Target = Target.RANDOM

func enter() -> void:
	match target:
		Target.RANDOM:
			if randi() % 2 == 0:
				character.direction = Constant.Direction.LEFT
			else:
				character.direction = Constant.Direction.RIGHT
		Target.PLAYER:
			if Game.get_player().global_position.x < character.global_position.x:
				character.direction = Constant.Direction.LEFT
			else:
				character.direction = Constant.Direction.RIGHT
		Target.PLAYER_INVERT:
			if Game.get_player().global_position.x < character.global_position.x:
				character.direction = Constant.Direction.RIGHT
			else:
				character.direction = Constant.Direction.LEFT
		Target.TURN:
			if character.direction == Constant.Direction.LEFT:
				character.direction = Constant.Direction.RIGHT
			else:
				character.direction = Constant.Direction.LEFT

func tick(_delta: float) -> BTState:
	return BTState.SUCCESS
