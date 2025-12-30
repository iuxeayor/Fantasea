extends State

func enter() -> void:
	character.alive = false
	# 动画音效
	character.animation_play("hurt")
	SoundManager.play_sfx("PlayerDie")
	# 关闭控制
	InputManager.disabled = true
	character.hurtbox.disabled = true
	character.velocity.x = - character.face_direction * Constant.KNOCKBACK_HORIZONTAL_SPEED
	character.velocity.y = Constant.KNOCKBACK_VERTICAL_VELOCITY
	# 结束效果
	Engine.time_scale = 0.1
	Game.get_game_scene().game_camera.shake(8, 0.2)
	Game.get_game_scene().camera_remote.set_deferred("remote_path", NodePath(""))
	character.dead_particle.restart()
	character.dead_slow_timer.start()
	character.collision_shape_2d.set_deferred("disabled", true)


func tick(delta: float) -> void:
	character.move(delta,
		- character.face_direction,
		Constant.MOVE_SPEED,
		Constant.MOVE_SPEED * Constant.ACCELERATION_MULTIPLIER,
		Constant.gravity)
