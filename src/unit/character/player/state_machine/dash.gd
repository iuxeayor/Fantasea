extends State

var dash_direction: Constant.Direction = Constant.Direction.RIGHT

func enter() -> void:
	SoundManager.play_sfx("PlayerDash")
	character.animation_play("dash")
	character.dashing_timer.start()
	character.velocity.y = 0
	# 判断操作方向
	if character.control_direction == Constant.ControlDirection.NONE:
		dash_direction = character.face_direction
	else:
		dash_direction = character.control_direction
	character.velocity.x = dash_direction * Constant.MAX_DASH_SPEED
	character.dash_particle.emitting = true
	character.control_manager.dashed = true

func exit() -> void:
	character.dash_particle.emitting = false
	character.dashing_timer.stop()
	character.dash_cd_timer.start()
	character.velocity.x /= 2

func tick(delta: float) -> void:
	character.move(delta,
		dash_direction,
		Constant.MAX_DASH_SPEED,
		Constant.MAX_DASH_SPEED * Constant.ACCELERATION_MULTIPLIER,
		0)
	character.refresh_control_direction()
	var want_stop: bool = true if (character.is_on_wall()
		or (character.control_direction != Constant.ControlDirection.NONE
		and character.control_direction != dash_direction)) else false
	var can_stop: bool = character.dashing_timer.time_left < character.dashing_timer.wait_time * 0.5
	if (character.dashing_timer.is_stopped()
		or (want_stop
		and can_stop)):
		change_to("ActionSubFSM")
