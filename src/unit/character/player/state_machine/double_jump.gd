extends State

func enter() -> void:
	character.animation_play("jump")
	SoundManager.play_sfx("PlayerDoubleJump")
	character.double_jump_particle.restart()
	# Timer affecting jumps
	character.control_manager.control_buffer_timer.get("jump").stop()
	character.coyote_timer.get("ground").stop()
	character.coyote_timer.get("wall").stop()
	character.jumping_timer.start() # Used to maintain a jumping state for a period of time when hitting the head
	character.control_manager.double_jumped = true
	# Jump up
	character.velocity.y = Constant.DOUBLE_JUMP_VELOCITY

func exit() -> void:
	character.jumping_timer.stop()

func tick(delta: float) -> void:
	# Air movement
	character.move(delta,
		character.control_direction,
		Constant.MOVE_SPEED,
		Constant.MOVE_SPEED * Constant.ACCELERATION_MULTIPLIER,
		Constant.gravity)
	# A short press of the jump button will only perform a minimal jump.
	if (not InputManager.is_action_pressed("jump")
		and character.velocity.y <= Constant.MIN_JUMP_VELOCITY):
		character.velocity.y = Constant.MIN_JUMP_VELOCITY
	# Even if you hit your head, you won't fall within the minimum jump time, preventing immediate descent when hitting the ceiling.
	if (character.is_on_ceiling()
		and not character.jumping_timer.is_stopped()):
		character.velocity.y = -1
	# When the velocity direction changes downward, switch to the falling state.
	if character.velocity.y >= 0:
		change_to("Fall")
		return
	# Start the coyote time when sticking to the wall to prevent being unable to wall jump if you act before falling.
	if character.catching_wall():
		character.coyote_timer.get("wall").start()
