extends State

func enter() -> void:
	character.animation_play("throw")
	character.shoot_cd_timer.start()
	var watermelon_seed: CharacterBody2D = Game.get_object("watermelon_seed")
	if watermelon_seed == null:
		return
	var damage: int = Util.get_shoot_power(
		Status.player_status.number_collection.get("weapon_level", 0))
	if Status.has_collection("lemon_slice"):
		damage += 1
	watermelon_seed.use(character.throw_point.global_position,
		Vector2(character.face_direction * 260, 0),
		damage)

func tick(delta: float) -> void:
	if character.animation_player.current_animation != "throw":
		change_to("ActionSubFSM")
		return
	# 移动
	character.refresh_control_direction()
	character.refresh_face_direction()
	character.move(delta,
		character.control_direction,
		Constant.MOVE_SPEED,
		Constant.MOVE_SPEED * Constant.ACCELERATION_MULTIPLIER,
		Constant.gravity)
