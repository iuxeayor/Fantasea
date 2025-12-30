extends State


func enter() -> void:
	character.animation_play("throw")
	var jelly: CharacterBody2D = Game.get_game_scene().jelly
	if jelly == null:
		return
	character.control_manager.threw_jelly = true
	jelly.use(character.throw_point.global_position,
			Vector2(character.face_direction * 260, -100))

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
