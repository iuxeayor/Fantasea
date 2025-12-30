extends State

func enter() -> void:
	SoundManager.play_sfx("PlayerHit")
	character.hurt_particle.restart()
	character.animation_play("hurt")
	character.hurtbox.disabled = true
	if Status.has_collection("stinky_tofu"):
		character.hurt_timer.start(Constant.EXTEND_HURT_TIME)
	else:
		character.hurt_timer.start(Constant.HURT_TIME)
	character.set_process(true)
	character.velocity.x = - character.face_direction * Constant.KNOCKBACK_HORIZONTAL_SPEED
	character.velocity.y = Constant.KNOCKBACK_VERTICAL_VELOCITY
	Game.get_game_scene().game_camera.shake(2, 0.3)
	Engine.time_scale = 0.5
	character.hurt_slow_timer.start()
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
