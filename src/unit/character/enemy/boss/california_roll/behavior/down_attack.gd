extends Action

func enter() -> void:
	character.gravity = Constant.gravity * 2
	character.animation_play("down_attack")
	Game.get_game_scene().left_ice_platform.set_collision_layer_value(1, false)
	Game.get_game_scene().right_ice_platform.set_collision_layer_value(1, false)
	character.down_afterimage_timer.start()
	var afterimage: Node2D = Game.get_object("roll_afterimage")
	if afterimage == null:
		return
	afterimage.spawn(character.global_position, character.direction, true)

func exit() -> void:
	character.gravity = Constant.gravity
	character.down_hitbox.disabled = true
	Game.get_game_scene().left_ice_platform.set_collision_layer_value(1, true)
	Game.get_game_scene().right_ice_platform.set_collision_layer_value(1, true)
	character.down_afterimage_timer.stop()

func tick(_delta: float) -> BTState:
	if character.velocity.y == 0 and character.is_on_floor():
		return BTState.SUCCESS
	return BTState.RUNNING
