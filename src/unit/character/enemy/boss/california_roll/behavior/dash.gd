extends Action

const SPEED: float = 360

func enter() -> void:
	character.velocity.x = character.direction * SPEED
	character.dash_afterimage_timer.start()
	var afterimage: Node2D = Game.get_object("roll_afterimage")
	if afterimage == null:
		return
	afterimage.spawn(character.global_position, character.direction, false)

func exit() -> void:
	character.velocity.x = 0
	character.dash_afterimage_timer.stop()

func tick(_delta: float) -> BTState:
	if character.player_checker.is_colliding() or _is_cross_player():
		return BTState.SUCCESS
	return BTState.RUNNING

func _is_cross_player() -> bool:
	if (character.direction == Constant.Direction.LEFT):
		return character.global_position.x < max(
			Game.get_game_scene().LEFT_X, 
			Game.get_player().global_position.x - 64)
	else:
		return character.global_position.x > min(
			Game.get_game_scene().RIGHT_X, 
			Game.get_player().global_position.x + 64)
