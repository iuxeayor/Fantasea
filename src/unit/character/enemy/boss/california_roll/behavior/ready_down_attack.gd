extends Action

const VELO_Y: float = -240

func enter() -> void:
	character.animation_play("ready_down")
	character.velocity = Vector2(0, VELO_Y)
	Game.get_game_scene().left_ice_platform.set_collision_layer_value(1, false)
	Game.get_game_scene().right_ice_platform.set_collision_layer_value(1, false)

func exit() -> void:
	Game.get_game_scene().left_ice_platform.set_collision_layer_value(1, true)
	Game.get_game_scene().right_ice_platform.set_collision_layer_value(1, true)

func tick(_delta: float) -> BTState:
	if character.velocity.y >= 0:
		return BTState.SUCCESS
	return BTState.RUNNING
