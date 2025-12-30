extends "res://src/scene/game/base/ship_scene.gd"

var storying: bool = false:
	set(v):
		storying = v
		if storying:
			Engine.time_scale = 1
		else:
			Engine.time_scale = Config.game_speed

@onready var player_checker: Area2D = $Units/PlayerChecker
@onready var glass: Node2D = $Units/Glass

func _input(event: InputEvent) -> void:
	if storying and player.alive:
		if event.is_action_pressed("ui_accept"):
			Engine.time_scale = 4
		elif event.is_action_released("ui_accept"):
			Engine.time_scale = 1

func _on_player_checker_body_entered(body: Node2D) -> void:
	if body != player:
		return
	player_checker.queue_free()
	storying = true
	InputManager.disabled = true
	player.velocity.x = 0
	SoundManager.play_sfx("IcePlatformBreaking")
	game_camera.shake(1, 1)
	await UIManager.special_effect.movie_in(1)
	await get_tree().create_timer(0.5).timeout
	SoundManager.play_sfx("IcePlatformBreaking")
	game_camera.shake(1, 1)
	Game.get_player().imbalance(2)
	await get_tree().create_timer(2).timeout
	game_camera.shake(4, 2)
	glass.glass_break()
