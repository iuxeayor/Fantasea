extends Action

enum Target {
	PLAYER,
	RANDOM
}



@export var target: Target = Target.PLAYER

func enter() -> void:
	match target:
		Target.PLAYER:
			var player_x: float = Game.get_player().global_position.x
			if player_x < character.global_position.x:
				character.direction = Constant.Direction.LEFT
			else:
				character.direction = Constant.Direction.RIGHT
		Target.RANDOM:
			if randi() % 2 == 0:
				character.direction = Constant.Direction.LEFT
			else:
				character.direction = Constant.Direction.RIGHT

func tick(_delta: float) -> BTState:
	return BTState.SUCCESS
