extends Action

func tick(_delta: float) -> BTState:
	if (((character.front_player_checker.is_colliding
		and character.front_player_checker.get_collider() is Player)
		or (character.back_player_checker.is_colliding()
		and character.back_player_checker.get_collider() is Player)
		or (character.top_player_checker.is_colliding()
		and character.top_player_checker.get_collider() is Player))
		and character.attack_cooldown_timer.is_stopped()):
		return BTState.SUCCESS
	return BTState.FAILURE
