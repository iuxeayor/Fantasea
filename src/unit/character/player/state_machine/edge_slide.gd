extends State

func enter() -> void:
	# 地面状态，重置冲刺和二段跳
	character.control_manager.double_jumped = false
	character.control_manager.dashed = false

func tick(delta: float) -> void:
	# Idle的拓展，所以与Idle的tick方法基本一致
	# 穿越平台
	if InputManager.is_action_pressed("drop"):
		character.drop_platform()
	# 受到果冻的推动
	if Game.get_game_scene().jelly.is_pushing_player():
		change_to("Bouncy")
		return
	# 不在地面上，转到Fall状态
	if not character.is_on_floor():
		change_to("Fall")
		return
	# 跳跃
	if character.control_manager.control_request("jump"):
		change_to("Jump")
		return
	# 有操作输入，转到Run状态
	if (character.control_direction != Constant.ControlDirection.NONE
		and not character.bottom_wall_checker.is_colliding()): # 不在墙边
		change_to("Run")
		return
	# 按下回血键，转到Healing状态
	if (InputManager.is_action_pressed("heal")
		and character.can_heal()):
		change_to("Healing")
		return
	character.refresh_control_direction()
	character.refresh_face_direction()
	character.move(delta,
		character.face_direction,
		Constant.EDGE_SLIDE_VELOCITY,
		Constant.EDGE_SLIDE_VELOCITY * Constant.ACCELERATION_MULTIPLIER,
		Constant.gravity)
	# 判断是否已经离开边缘
	if (character.front_edge_checker.is_colliding()
		or character.back_edge_checker.is_colliding()):
		change_to("Idle")
