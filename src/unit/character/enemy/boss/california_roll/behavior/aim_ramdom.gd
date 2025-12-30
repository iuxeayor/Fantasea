extends Action

func enter() -> void:
	var target: Vector2 = (character.shoot_point.global_position
		+ Vector2(character.direction * randf_range(4, 16), 
			randf_range(-8, 4)))
	Game.get_game_scene().bullet_aim(character.shoot_point.global_position, target)

func tick(_delta: float) -> BTState:
	return BTState.SUCCESS
