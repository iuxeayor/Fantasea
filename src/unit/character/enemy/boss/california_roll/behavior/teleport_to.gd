extends Action

enum Target {
	PLAYER_TOP,
	LEFT_EDGE,
	RIGHT_EDGE,
	RANDOM_TOP,
	FAR_EDGE,
	LEFT_PLATFORM,
	RIGHT_PLATFORM,
	CLOSE_PLATFORM
}

@export var target: Target = Target.PLAYER_TOP

var target_pos: Vector2 = Vector2.ZERO

func enter() -> void:
	character.teleport_particle.trigger(character.global_position + Vector2(0, -10))
	var scene: Scene = Game.get_game_scene()
	var player_pos: Vector2 = Game.get_player().global_position
	target_pos = character.global_position
	match target:
		Target.PLAYER_TOP:
			target_pos = Vector2(clampf(player_pos.x, scene.LEFT_X, scene.RIGHT_X), scene.SKY_Y)
		Target.LEFT_EDGE:
			target_pos = scene.LEFT_POINT
		Target.RIGHT_EDGE:
			target_pos = scene.RIGHT_POINT
		Target.RANDOM_TOP:
			target_pos = Vector2(randf_range(scene.LEFT_X, scene.RIGHT_X), scene.SKY_Y)
		Target.FAR_EDGE: # 离玩家远的边缘
			if player_pos.x < scene.MID_X:
				target_pos = scene.RIGHT_POINT
			else:
				target_pos = scene.LEFT_POINT
		Target.LEFT_PLATFORM:
			target_pos = scene.LEFT_PLATFORM_POINT
		Target.RIGHT_PLATFORM:
			target_pos = scene.RIGHT_PLATFORM_POINT
		Target.CLOSE_PLATFORM:
			if player_pos.x < scene.MID_X:
				target_pos = scene.LEFT_PLATFORM_POINT
			else:
				target_pos = scene.RIGHT_PLATFORM_POINT
	character.animation_play("idle")
	character.velocity = Vector2.ZERO

func exit() -> void:
	SoundManager.play_sfx("RollTeleport")
	character.global_position = target_pos
	character.teleport_particle.trigger(character.global_position + Vector2(0, -10))


func tick(_delta: float) -> BTState:
	return BTState.SUCCESS
