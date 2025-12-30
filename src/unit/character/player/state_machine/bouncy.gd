extends State

func enter() -> void:
	# 播放
	character.animation_play("jump")
	SoundManager.play_sfx("PlayerBounce")
	# 影响跳跃的计时器
	character.control_manager.control_buffer_timer.get("jump").stop()
	character.coyote_timer.get("ground").stop()
	character.coyote_timer.get("wall").stop()
	character.jumping_timer.start() # 用于撞头时保持一段时间的跳跃状态
	# 跳起
	character.velocity.y = Constant.JELLY_BOUNCE_VELOCITY

func exit() -> void:
	character.jumping_timer.stop()

func tick(delta: float) -> void:
	# 空中移动
	character.refresh_control_direction()
	character.refresh_face_direction()
	character.move(delta,
		character.control_direction,
		Constant.MOVE_SPEED,
		Constant.MOVE_SPEED * Constant.ACCELERATION_MULTIPLIER,
		Constant.gravity)
	# 跳跃最小时间内即使撞头也不会下落，防止撞到天花板时马上下落
	if (character.is_on_ceiling()
		and not character.jumping_timer.is_stopped()):
		character.velocity.y = -1
	# 速度方向变为向下时，切换到下落状态
	if character.velocity.y >= 0:
		change_to("Fall")
		return
	# 贴墙时启动郊狼时间，防止到下落前操作会无法墙跳
	if character.catching_wall():
		character.coyote_timer.get("wall").start()
