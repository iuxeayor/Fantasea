extends State

func enter() -> void:
	character.animation_play("fall")

func tick(delta: float) -> void:
	# 有甜酒酿并且按下回血键，转到SkyHealing状态
	if (InputManager.is_action_pressed("heal")
		and character.can_heal()
		and Status.has_collection("sweet_jiuniang")):
		change_to("SkyHealing")
		return
	# 落地，切换到地面状态
	if character.is_on_floor():
		if (is_zero_approx(character.velocity.x)
			or character.bottom_wall_checker.is_colliding()):
			change_to("Idle")
			return
		change_to("Run")
		return
	# 向墙壁移动并且未攻击，切换到墙壁滑动状态
	# 避免切图导致的问题，速度不向下时不切换
	# 墙壁是冰时不切换
	# 出界无法滑墙
	if (character.catching_wall()
		and character.velocity.y >= 0
		and not character.ice_wall_checker.is_colliding()
		and not Game.get_game_scene().is_out_of_bounds(character.global_position)):
		change_to("WallSlide")
		return
	# 跳跃
	if character.control_manager.control_request("jump"):
		# 地面郊狼时间
		if character.in_coyote_time("ground"):
			change_to("Jump")
			return
		# 墙跳郊狼时间
		if character.in_coyote_time("wall"):
			change_to("WallJump")
			return
		# 二段跳
		if (character.control_manager.valid_double_jump_request()
			and Status.has_collection("jelly_pouch")):
			change_to("DoubleJump")
			return
	# 移动
	character.refresh_control_direction()
	character.refresh_face_direction()
	character.move(delta,
		character.control_direction,
		Constant.MOVE_SPEED,
		Constant.MOVE_SPEED * Constant.ACCELERATION_MULTIPLIER,
		Constant.gravity)
