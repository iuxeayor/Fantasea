extends Action

func tick(_delta: float) -> BTState:
	if (((character.left_player_checker.is_colliding()
		and character.left_player_checker.get_collider() is Player)
		or (character.right_player_checker.is_colliding()
		and character.right_player_checker.get_collider() is Player))
		and Game.get_player().velocity.y < 0):
		return BTState.FAILURE
	return BTState.SUCCESS
