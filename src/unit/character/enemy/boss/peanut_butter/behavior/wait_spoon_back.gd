extends Action

func enter() -> void:
	super ()
	character.animation_play("wait_spoon")

func tick(_delta: float) -> BTState:
	if Game.get_game_scene().spoon_bullet.is_idle():
		return BTState.SUCCESS
	return BTState.RUNNING
