extends State

func enter() -> void:
	character.animation_play("fall")
	character.dash_shield_particle.restart()
	SoundManager.play_sfx("PlayerDashShield")
	character.hurtbox.disabled = true
	if Status.has_collection("stinky_tofu"):
		character.hurt_timer.start(Constant.EXTEND_DASH_SHIELD_HURT_TIME)
	else:
		character.hurt_timer.start(Constant.DASH_SHIELD_HURT_TIME)
	character.set_process(true)
	character.velocity.x = - character.face_direction * Constant.DASH_SHIELD_KNOCKBACK_HORIZONTAL_SPEED
	character.velocity.y = Constant.DASH_SHIELD_KNOCKBACK_VERTICAL_VELOCITY
	Game.get_game_scene().game_camera.shake(2, 0.2)
	Engine.time_scale = 0.5
	character.hurt_slow_timer.start()
	character.healing_hint.stop()
	if Status.has_collection("straw_glasses"):
		character.auto_heal_timer.start()

func tick(delta: float) -> void:
	if character.is_on_floor() or character.hurt_timer.is_stopped():
		if character.is_on_floor():
			character.velocity.x = 0
		change_to("AttackSubFSM")
		return
	character.move(delta,
		- character.face_direction,
		Constant.KNOCKBACK_HORIZONTAL_SPEED,
		Constant.KNOCKBACK_HORIZONTAL_SPEED * Constant.ACCELERATION_MULTIPLIER,
		Constant.gravity)
