extends "res://src/scene/game/base/forest_scene.gd"

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
	player.animation_play("sleeping")
	await get_tree().create_timer(1).timeout
	UIManager.special_effect.movie_in(0)
	UIManager.special_effect.fade_in(0)
	UIManager.special_effect.cover_out()
	await UIManager.special_effect.fade_out(1)
	await get_tree().create_timer(2).timeout
	whole_wheat_bread_npc.direction = Constant.Direction.RIGHT
	whole_wheat_bread_npc.animation_play("wear_run")
	animation_player.play("leave")
	await get_tree().create_timer(0.5).timeout
	UIManager.special_effect.fade_in(1)
	

func get_scene_index() -> int:
	return 176


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name != "leave":
		return
	UIManager.special_effect.cover_in()
	Game.load_game(Game.save_name)
