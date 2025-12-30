extends "res://src/scene/game/base/cave_scene.gd"

const PLAYER_START_POSITION: Vector2 = Vector2(48, 176)
const BOSS_START_POSITION: Vector2 = Vector2(336, 176)
const NPC_START_POSITION: Vector2 = Vector2(344, 176)

var storying: bool = false:
	set(v):
		storying = v
		if storying:
			Engine.time_scale = 1
		else:
			Engine.time_scale = Config.game_speed

@onready var baijiu: Boss = $Units/Enemies/Baijiu
@onready var game_breakable_object: TileMapLayer = $Units/GameBreakableObject
@onready var cave_lantern: Node2D = $Units/CaveLantern
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var player_light: PointLight2D = $Player/PlayerLight
@onready var top_collision: CollisionShape2D = $Units/BattleWall/TopCollision
@onready var left_collision: CollisionShape2D = $Units/BattleWall/LeftCollision
@onready var baijiu_npc: CharacterBody2D = $Units/BaijiuNpc

func _input(event: InputEvent) -> void:
	if storying and player.alive:
		if event.is_action_pressed("ui_accept"):
			Engine.time_scale = 4
		elif event.is_action_released("ui_accept"):
			Engine.time_scale = 1

func _before_ready() -> void:
	super()
	cave_lantern.hide()
	baijiu.hide()
	left_collision.set_deferred("disabled", true)
	left_collision.hide()
	if explore_status == Constant.ExploreStatus.COMPLETE:
		baijiu.queue_free()
		baijiu_npc.dialog.root_dialog = baijiu_npc.end_dialog
		game_breakable_object.queue_free()
		left_collision.queue_free()
		top_collision.queue_free()

func _on_baijiu_stage_change() -> void:
	# 3阶段破坏地面
	# 4阶段关闭灯笼
	if baijiu.battle_stage == 2:
		await get_tree().create_timer(1.5).timeout
		game_breakable_object.hit()
		await get_tree().create_timer(1).timeout
		game_breakable_object.hit()
		await get_tree().create_timer(1).timeout
		game_breakable_object.hit()
	if baijiu.battle_stage == 3:
		await get_tree().create_timer(2).timeout
		if game_breakable_object != null:
			game_breakable_object.dead()
		cave_lantern.animation_player.play("end")
		animation_player.play("light")

func _on_baijiu_npc_updated(context: String) -> void:
	if context != "battle":
		return
	storying = true
	InputManager.disabled = true
	baijiu_npc.dialog.disabled = true
	await UIManager.special_effect.fade_in(1)
	left_collision.set_deferred("disabled", false)
	left_collision.show()
	player_light.energy = 0
	cave_lantern.show()
	baijiu_npc.hide()
	baijiu_npc.global_position = object_pool.global_position
	player.face_direction = Constant.Direction.RIGHT
	player.global_position = PLAYER_START_POSITION
	baijiu.direction = Constant.Direction.LEFT
	baijiu.global_position = BOSS_START_POSITION
	baijiu.show()
	UIManager.status_panel.update_boss_health(baijiu.status.health, baijiu.status.max_health)
	UIManager.status_panel.boss_health_bar_container.show()
	await get_tree().create_timer(1).timeout
	player.state_machine.disabled = true
	player.animation_play("sleeping")
	await UIManager.special_effect.movie_in(1)
	player.animation_play("awake")
	await UIManager.special_effect.fade_out(1)
	await UIManager.special_effect.movie_out(1)
	player.state_machine.disabled = false
	InputManager.disabled = false
	baijiu.start_battle()
	SoundManager.play_bgm(preload("res://asset/music/boss_late.ogg"))
	storying = false
	
func _on_baijiu_defeated() -> void:
	Achievement.set_achievement(Achievement.ID.DEFEAT_BAIJIU)
	storying = true
	InputManager.disabled = true
	# 移除玩家碰撞
	player.hurt_timer.stop()
	player.reset_flash()
	player.hurtbox.disabled = true
	baijiu.stop_battle()
	baijiu.animation_play("hurt")
	baijiu.gravity = 0
	baijiu.velocity = Vector2(
		randf_range(-60, 60),
		randf_range(-60, -60)
	)
	await UIManager.special_effect.fade_in(1)
	SoundManager.play_bgm(bgm)
	await get_tree().create_timer(1).timeout
	UIManager.status_panel.boss_health_bar_container.hide()
	cave_lantern.queue_free()
	baijiu.queue_free()
	left_collision.queue_free()
	top_collision.queue_free()
	player_light.energy = 1.1
	baijiu_npc.global_position = NPC_START_POSITION
	baijiu_npc.direction = Constant.Direction.LEFT
	baijiu_npc.dialog.root_dialog = baijiu_npc.end_dialog
	baijiu_npc.show()
	player.global_position = PLAYER_START_POSITION
	player.state_machine.disabled = true
	player.animation_play("sleeping")
	await UIManager.special_effect.movie_in(1)
	await UIManager.special_effect.fade_out(1)
	player.status.health = player.status.max_health
	player.status.potion = player.status.max_potion
	player.animation_play("awake")
	await get_tree().create_timer(2).timeout
	await UIManager.special_effect.movie_out(1)
	player.state_machine.disabled = false
	InputManager.disabled = false
	storying = false
	explore_status = Constant.ExploreStatus.COMPLETE
