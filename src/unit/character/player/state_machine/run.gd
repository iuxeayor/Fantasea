extends State

func enter() -> void:
	character.animation_play("run")
	# 地面状态，重置冲刺和二段跳
	character.control_manager.double_jumped = false
	character.control_manager.dashed = false

func exit() -> void:
	character.coyote_timer.get("ground").start()

func tick(delta: float) -> void:
	# 穿越平台
	if InputManager.is_action_pressed("drop"):
		character.drop_platform()
	# 受到果冻的推动
	if Game.get_game_scene().jelly.is_pushing_player():
		change_to("Bouncy")
		return
	# 不在地面上，切换到下落状态
	if not character.is_on_floor():
		change_to("Fall")
		return
	# 跳跃
	if character.control_manager.control_request("jump"):
		change_to("Jump")
		return
	# 移动
	character.refresh_control_direction()
	character.refresh_face_direction()
	var acceleration: float = Constant.MOVE_SPEED * Constant.ACCELERATION_MULTIPLIER
	# 在冰面上时，减缓加速度加速度
	if character.ice_ground_checker.is_colliding():
		acceleration = Constant.MOVE_SPEED
	character.move(delta,
		character.control_direction,
		Constant.MOVE_SPEED,
		acceleration,
		Constant.gravity)
	# 停下
	if (is_zero_approx(character.velocity.x)
		or (character.bottom_wall_checker.is_colliding()
		and character.is_on_wall())):
		change_to("Idle")
		return
	# 按下回血键，转到Healing状态
	if (InputManager.is_action_pressed("heal")
		and character.can_heal()):
		change_to("Healing")
		return
