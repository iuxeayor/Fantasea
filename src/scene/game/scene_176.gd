extends "res://src/scene/game/base/ship_scene.gd"

@onready var player_checker: Area2D = $Units/PlayerChecker
@onready var pineapple_bun: CharacterBody2D = $Units/PineappleBun

var storying: bool = false:
	set(v):
		storying = v
		if storying:
			Engine.time_scale = 1
		else:
			Engine.time_scale = Config.game_speed

func _input(event: InputEvent) -> void:
	if storying and player.alive:
		if event.is_action_pressed("ui_accept"):
			Engine.time_scale = 4
		elif event.is_action_released("ui_accept"):
			Engine.time_scale = 1

func _before_ready() -> void:
	super()
	if explore_status == Constant.ExploreStatus.COMPLETE:
		player_checker.queue_free()
		pineapple_bun.dialog.root_dialog = pineapple_bun.normal_dialog

func _on_player_checker_body_entered(body: Node2D) -> void:
	if not body is Player:
		return
	player_checker.queue_free()
	storying = true
	InputManager.disabled = true
	player.velocity.x = 0
	pineapple_bun.direction = Constant.Direction.LEFT
	await UIManager.special_effect.movie_in(1)
	pineapple_bun.dialog.disabled = false
	


func _on_pineapple_bun_updated(context: String) -> void:
	match context:
		"story":
			pineapple_bun.dialog.disabled = true
			pineapple_bun.dialog.root_dialog = pineapple_bun.normal_dialog
			await UIManager.special_effect.movie_out(1)
			storying = false
			InputManager.disabled = false
			explore_status = Constant.ExploreStatus.COMPLETE
		"memory":
			pineapple_bun.dialog.disabled = true
			pineapple_bun.animation_play("hammer")
			await get_tree().create_timer(1.5).timeout
			UIManager.special_effect.cover_in()
			SoundManager.play_sfx("HammerHit")
			SoundManager.stop_bgm()
			Game.get_game_scene().to_status()
			Status.save_to_file(Game.save_name)
			Game.story_change_scene("res://src/scene/game/special/scene_memory_ship.tscn")
