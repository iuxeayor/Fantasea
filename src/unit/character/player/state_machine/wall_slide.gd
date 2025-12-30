extends State

func enter() -> void:
	character.animation_play("wall_slide")
	character.coyote_timer.get("ground").stop()
	character.wall_slide_particle.emitting = true
	# 重置冲刺和二段跳
	character.control_manager.double_jumped = false
	character.control_manager.dashed = false
	# 滑墙初速度过大时，快速减速
	if character.velocity.y > Constant.WALL_SLIDE_VELOCITY:
		character.velocity.y = (character.velocity.y) / log(character.velocity.y + 1) + Constant.WALL_SLIDE_VELOCITY

func exit() -> void:
	# 关闭滑墙粒子
	character.wall_slide_particle.emitting = false
	character.coyote_timer.get("ground").stop()
	character.coyote_timer.get("wall").start()
	character.face_direction = - character.face_direction
	character.control_direction = Constant.ControlDirection.NONE

func tick(delta: float) -> void:
	character.coyote_timer.get("ground").start()
	# 有甜酒酿并且按下回血键，转到SkyHealing状态
	if (InputManager.is_action_pressed("heal")
		and character.can_heal()
		and Status.has_collection("sweet_jiuniang")):
		change_to("SkyHealing")
		return
	# 落地，切换到地面状态
	if character.is_on_floor():
		change_to("Idle")
		return
	if character.control_manager.control_request("jump"):
		change_to("WallJump")
		return
	# 停止滑墙或攻击，恢复掉落
	# 滑到冰墙上也无法继续滑墙
	# 出界无法滑墙
	if (not character.catching_wall()
		or character.ice_wall_checker.is_colliding()
		or Game.get_game_scene().is_out_of_bounds(character.global_position)):
		change_to("Fall")
		return
	# 下落速度加速到恒定速度
	character.refresh_control_direction()
	character.refresh_face_direction()
	character.velocity.y = move_toward(character.velocity.y,
		Constant.WALL_SLIDE_VELOCITY,
		Constant.WALL_SLIDE_VELOCITY * Constant.ACCELERATION_MULTIPLIER * delta)
	# 滑墙粒子在最大速度时开启
	# player.wall_slide_particle.emitting = is_equal_approx(player.velocity.y, PLAYER.WALL_SLIDE_VELOCITY)
