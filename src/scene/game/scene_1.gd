extends "res://src/scene/game/base/forest_scene.gd"

@onready var start_entry_point: EntryPoint = $Entrances/StartEntryPoint
@onready var dialog: Node2D = $Player/Dialog

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


func play_story() -> void:
	storying = true
	# 播放初始动画
	InputManager.disabled = true
	# 处理玩家位置
	game_camera.position_smoothing_enabled = false
	player.state_machine.disabled = true
	player.global_position = start_entry_point.global_position
	get_tree().paused = false
	game_camera.set_deferred("position_smoothing_enabled", true)
	player.animation_play("sleeping")
	await UIManager.special_effect.movie_in(0)
	await UIManager.special_effect.fade_out(1)
	await get_tree().create_timer(1).timeout
	player.animation_play("awake")
	await player.animation_player.animation_finished
	dialog.disabled = false

func _on_dialog_closed() -> void:
	await UIManager.special_effect.movie_out(1)
	player.state_machine.disabled = false
	InputManager.disabled = false
	storying = false
