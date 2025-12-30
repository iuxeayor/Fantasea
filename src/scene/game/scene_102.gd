extends "res://src/scene/game/base/desert_scene.gd"

var storying: bool = false:
	set(v):
		storying = v
		if storying:
			Engine.time_scale = 1
		else:
			Engine.time_scale = Config.game_speed

@onready var butter_npc: CharacterBody2D = $Units/ButterNpc
@onready var breakable_object_2: TileMapLayer = $Units/BreakableObject2
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _before_ready() -> void:
	super()
	if Status.scene_status.story.get("butter_break", false):
		butter_npc.queue_free()
		breakable_object_2.queue_free()

func _input(event: InputEvent) -> void:
	if storying and player.alive:
		if event.is_action_pressed("ui_accept"):
			Engine.time_scale = 4
		elif event.is_action_released("ui_accept"):
			Engine.time_scale = 1

func _on_breakable_object_2_completed() -> void:
	storying = true
	InputManager.disabled = true
	butter_npc.collision_shape_2d.set_deferred("disabled", true)
	butter_npc.direction = Constant.Direction.RIGHT
	butter_npc.dialog.root_dialog = butter_npc.break_dialog
	await UIManager.special_effect.movie_in(1)
	butter_npc.dialog.disabled = false

func _on_butter_npc_updated(context: String) -> void:
	if context != "break":
		return
	await get_tree().create_timer(0.5).timeout
	butter_npc.animation_play("walk")
	animation_player.play("break_end")
	await animation_player.animation_finished
	butter_npc.queue_free()
	Status.scene_status.story["butter_break"] = true
	await get_tree().create_timer(1).timeout
	await UIManager.special_effect.movie_out(1)
	storying = false
	InputManager.disabled = false
