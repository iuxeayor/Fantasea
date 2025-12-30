extends Action

enum Target {
	PLAYER,
	FAR_POINT
	}

@export var target: Target = Target.PLAYER
	
func enter() -> void:
	super ()
	var target_x: float = character.spoon_point.global_position.x
	var target_y: float = character.spoon_point.global_position.y
	match target:
		Target.PLAYER:
			target_x = Game.get_player().global_position.x
		Target.FAR_POINT:
			if randi() % 2 == 0:
				# 高处
				target_x = character.spoon_point.global_position.x + character.direction * 280
				target_y = character.spoon_point.global_position.y - 24
			else:
				# 低处
				target_x = character.spoon_point.global_position.x + character.direction * 280
	target_x = clampf(target_x, Game.get_game_scene().left_point.global_position.x, Game.get_game_scene().right_point.global_position.x)
	Game.get_game_scene().spoon_bullet.shoot(character.spoon_point.global_position,
		Vector2(target_x, target_y))


func tick(_delta: float) -> BTState:
	return BTState.SUCCESS
