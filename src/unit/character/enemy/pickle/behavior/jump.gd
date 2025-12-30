extends Action

func enter() -> void:
	var speed: float = randf_range(-30, 60)
	speed = clampf(speed * 2, -60, 90)
	character.velocity = Vector2(
		character.direction * speed,
		randf_range(-180, -300)
	)
	if character.animation_player.current_animation == "sleep":
		character.break_particle.restart()
		SoundManager.play_sfx("PickleBreak")
	character.animation_play("bounce")

func tick(_delta: float) -> BTState:
	return BTState.SUCCESS
