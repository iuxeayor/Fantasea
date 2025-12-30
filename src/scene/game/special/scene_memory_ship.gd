extends "res://src/scene/game/base/ship_scene.gd"

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var whole_wheat_bread_npc: CharacterBody2D = $Units/WholeWheatBreadNpc

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

func _ready() -> void:
	super()
	storying = true
	player.state_machine.disabled = true
	InputManager.disabled = true
	await get_tree().create_timer(2).timeout
	UIManager.special_effect.movie_in(0)
	UIManager.special_effect.fade_in(0)
	UIManager.special_effect.cover_out()
	await UIManager.special_effect.fade_out(1)
	await get_tree().create_timer(1).timeout
	player.animation_play("run")
	animation_player.play("start")

func get_scene_index() -> int:
	return 176


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"start":
			player.animation_play("idle")
			await get_tree().create_timer(0.5).timeout
			whole_wheat_bread_npc.direction = Constant.Direction.LEFT
			await get_tree().create_timer(0.5).timeout
			animation_player.play("jump")
		"jump":
			await get_tree().create_timer(1).timeout
			whole_wheat_bread_npc.dialog.disabled = false
		"throw":
			UIManager.special_effect.cover_in()
			await get_tree().create_timer(0.1).timeout
			SoundManager.play_sfx("PlayerDie")
			await get_tree().create_timer(2).timeout
			Game.story_change_scene("res://src/scene/game/special/scene_memory_forest.tscn")


func _on_whole_wheat_bread_npc_updated(context: String) -> void:
	if context != "steal":
		return
	await get_tree().create_timer(0.5).timeout
	player.face_direction = Constant.Direction.LEFT
	whole_wheat_bread_npc.animation_play("throw")
	animation_player.play("throw")

	
