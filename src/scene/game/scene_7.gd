extends "res://src/scene/game/base/forest_scene.gd"

var storying: bool = false:
	set(v):
		storying = v
		if storying:
			Engine.time_scale = 1
		else:
			Engine.time_scale = Config.game_speed

@onready var cracker: Npc = $Units/Cracker
@onready var cake_piece: Npc = $Units/CakePiece
@onready var door: Sprite2D = $Background/Prop/MantouHouse/Door
@onready var fake_door_collision: CollisionShape2D = $Units/House/HouseWall/FakeDoorCollision
@onready var mantou: Npc = $Units/House/Mantou
@onready var player_checker_start: Area2D = $Units/PlayerCheckerStart

func _before_ready() -> void:
	super ()
	if Status.scene_status.story.get("main_start", false): # 完成开局剧情
		player_checker_start.queue_free()
	if Status.scene_status.story.get("main_sleep", false):
		fake_door_collision.queue_free()
	else:
		cracker.queue_free()
		cake_piece.queue_free()
		door.queue_free()

func _input(event: InputEvent) -> void:
	if storying and player.alive:
		if event.is_action_pressed("ui_accept"):
			Engine.time_scale = 4
		elif event.is_action_released("ui_accept"):
			Engine.time_scale = 1

func _on_player_checker_start_body_entered(body: Node2D) -> void:
	if not body is Player:
		return
	player_checker_start.queue_free()
	storying = true
	InputManager.disabled = true
	await UIManager.special_effect.movie_in(1)
	mantou.animation_play("idle")
	await get_tree().create_timer(1).timeout
	mantou.dialog.disabled = false


func _on_mantou_updated(context: String) -> void:
	if context != "start":
		return
	await get_tree().create_timer(0.5).timeout
	mantou.animation_play("write")
	await UIManager.special_effect.movie_out(1)
	InputManager.disabled = false
	storying = false
	mantou.dialog.root_dialog = mantou.busy_dialog
	Status.scene_status.story["main_start"] = true
