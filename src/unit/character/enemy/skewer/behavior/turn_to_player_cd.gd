extends Action

func enter() -> void:
	super ()
	if not character.turn_cd_timer.is_stopped():
		return
	var target_direction: Constant.Direction = character.direction
	var player: Player = Game.get_player()
	if player.global_position.x + 4 < character.global_position.x:
		target_direction = Constant.Direction.LEFT
	elif player.global_position.x - 4 > character.global_position.x:
		target_direction = Constant.Direction.RIGHT
	if target_direction != character.direction:
		character.direction = target_direction
		character.turn_cd_timer.start()
	

func tick(_delta: float) -> BTState:
	return BTState.SUCCESS
