extends "res://src/scene/game/base/forest_scene.gd"

@onready var stick: StaticBody2D = $Units/Stick

# 教学
@onready var tutorial: CanvasLayer = $Tutorial
@onready var interact_tutorial: RichTextLabel = $Tutorial/Interact
@onready var interact_item_tutorial: RichTextLabel = $Tutorial/InteractItem
@onready var inventory_tutorial: RichTextLabel = $Tutorial/Inventory
@onready var attack_tutorial: RichTextLabel = $Tutorial/Attack
@onready var lantern: Node2D = $Units/Lantern
@onready var day_light: PointLight2D = $Lights/DayLight
@onready var dark_light: DirectionalLight2D = $Lights/DarkLight


func _before_ready() -> void:
	super ()
	attack_tutorial.area_collision_shape.set_deferred("disabled", true)
	interact_item_tutorial.area_collision_shape.set_deferred("disabled", true)
	# 已经打碎箱子，不再显示攻击教学
	if Status.scene_status.story.get("main_break", false):
		attack_tutorial.queue_free()
	else:
		# 箱子未打碎且已经收集木棍，则显示攻击教学
		if Status.player_status.number_collection.get("weapon_level", 0) > 0:
			attack_tutorial.area_collision_shape.set_deferred("disabled", false)
	if Status.scene_status.story.get("main_sleep", false):
		dark_light.energy = 0.5
		lantern.point_light_2d.energy = 0.6
		interact_item_tutorial.area_collision_shape.set_deferred("disabled", false)
		SoundManager.stop_rain()
	else:
		# 初始阶段
		day_light.queue_free()
		if stick != null:
			stick.queue_free()
		SoundManager.play_rain(false)
	# 场景完成后删除交互提示
	if explore_status == Constant.ExploreStatus.COMPLETE:
		interact_tutorial.queue_free()
		interact_item_tutorial.queue_free()
		

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory") and inventory_tutorial != null:
		inventory_tutorial.queue_free()

func _on_stick_completed() -> void:
	attack_tutorial.area_collision_shape.set_deferred("disabled", false)
	interact_item_tutorial.area_collision_shape.set_deferred("disabled", true)
	if inventory_tutorial == null:
		return
	inventory_tutorial.show_tween(0.5)
