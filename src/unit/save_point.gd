extends Node2D
class_name SavePoint

@export var player_direction: Constant.Direction = Constant.Direction.LEFT

@onready var dialog: Node2D = $Dialog
@onready var jump_to_point: Marker2D = $JumpToPoint
@onready var sit_point: Marker2D = $SitPoint
@onready var main_dialog: DialogContent = $Dialog/Main

func _ready() -> void:
	main_dialog.get_target("SAVE_POINT_SLEEPWALK").disabled = not Status.player_status.collection.get("nutmeg", false)

func trigger() -> void:
	# 动作
	InputManager.disabled = true
	_sitting_action()
	match Game.get_game_scene().scene_environment:
		Constant.SceneEnvironment.FOREST:
			Achievement.set_achievement(Achievement.ID.EXPLORE_FOREST)
		Constant.SceneEnvironment.ISLAND:
			Achievement.set_achievement(Achievement.ID.EXPLORE_ISLAND)
		Constant.SceneEnvironment.SNOWFIELD:
			Achievement.set_achievement(Achievement.ID.EXPLORE_SNOWFIELD)
		Constant.SceneEnvironment.DESERT:
			Achievement.set_achievement(Achievement.ID.EXPLORE_DESERT)
		Constant.SceneEnvironment.SHIP:
			Achievement.set_achievement(Achievement.ID.EXPLORE_SHIP)
		Constant.SceneEnvironment.CAVE:
			Achievement.set_achievement(Achievement.ID.EXPLORE_CAVE)
	Status.handle_achievement()

func _sitting_action() -> void:
	# 动作
	var player: Player = Game.get_player()
	player.state_machine.disabled = true
	player.auto_heal_timer.stop()
	player.animation_play("jump")
	player.velocity = Vector2.ZERO
	player.face_direction = player_direction
	player.animation_play("fall")
	var tween: Tween = create_tween()
	tween.tween_property(player, "global_position", jump_to_point.global_position, 0.15)
	await tween.finished
	tween = create_tween()
	tween.tween_property(player, "global_position", sit_point.global_position, 0.1)
	await tween.finished
	player.animation_play("sit")
	# 数据处理
	_handle_data()
	await _save()
	await get_tree().create_timer(0.1).timeout
	dialog.disabled = false

func _handle_data() -> void:
	if Game.get_player() != null:
		Game.get_player().fill_potion()
	Game.get_game_scene().to_status()
	UIManager.status_panel.display_note_update()
	UIManager.inventory_screen.map_container.mini_map.update(Status.scene_status.scene_explore)

func _save() -> void:
	# 保存
	Game.get_game_scene().to_status()
	Status.save_to_file(Game.save_name)
	await Status.saved

func _on_main_ended() -> void:
	var player: Player = Game.get_player()
	player.state_machine.disabled = false
	player.auto_heal_timer.start(Constant.FAST_AUTO_HEAL_TIME)
	if Status.has_collection("fresh_milk"):
		player.auto_heal_timer.wait_time = Constant.FAST_AUTO_HEAL_TIME
	else:
		player.auto_heal_timer.wait_time = Constant.AUTO_HEAL_TIME
	InputManager.disabled = false

func _on_rest_started() -> void:
	var player: Player = Game.get_player()
	player.animation_play("sleeping")
	dialog.disabled = true
	await dialog.animation_player.animation_finished
	# 休息
	player.status.health = player.status.max_health
	Status.scene_enemy_data.clear()
	# 例外，第一次睡觉会触发剧情
	if Status.scene_status.story.get("main_sleep", false) == false:
		Status.scene_status.story["main_sleep"] = true
		Achievement.set_achievement(Achievement.ID.STORY_START)
	await _save()
	Game.load_game(Game.save_name)

func _on_sleepwalk_started() -> void:
	var player: Player = Game.get_player()
	player.animation_play("sleeping")
	dialog.disabled = true
	await dialog.animation_player.animation_finished
	# 休息
	player.status.health = player.status.max_health
	Status.scene_enemy_data.clear()
	var target: int = 180
	match Game.get_game_scene().scene_environment:
		Constant.SceneEnvironment.FOREST:
			target = 7
		Constant.SceneEnvironment.DESERT:
			target = 90
		Constant.SceneEnvironment.SNOWFIELD:
			target = 70
		Constant.SceneEnvironment.SHIP:
			target = 172
		Constant.SceneEnvironment.CAVE:
			target = 200
	Game.get_game_scene().to_status()
	Game.sleepwalk_switch_game_scene(target)
