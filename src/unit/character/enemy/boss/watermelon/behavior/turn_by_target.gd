extends Action

enum Target {
	PLAYER,
	PLAYER_INVERSE,
}

@export var target: Target = Target.PLAYER ## 面向目标

func enter() -> void:
	super ()
	var player: Player = Game.get_player()
	var target_x: float = character.global_position.x
	match target:
		Target.PLAYER:
			target_x = player.global_position.x
		Target.PLAYER_INVERSE:
			if player.global_position.x < character.global_position.x:
				target_x += 64
			elif player.global_position.x > character.global_position.x:
				target_x -= 64
	if character.global_position.x < target_x:
		character.direction = Constant.Direction.RIGHT
	elif character.global_position.x > target_x:
		character.direction = Constant.Direction.LEFT

func tick(_delta: float) -> BTState:
	return BTState.SUCCESS
