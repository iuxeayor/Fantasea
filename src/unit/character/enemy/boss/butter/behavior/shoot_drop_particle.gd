extends Action

func enter() -> void:
	super ()
	character.drop_particle.trigger(character.global_position)
	Game.get_game_scene().game_camera.shake(1, 0.3)
	SoundManager.play_sfx("ButterLand")

func tick(_delta: float) -> BTState:
	return BTState.SUCCESS
