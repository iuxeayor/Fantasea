extends "res://src/scene/game/base/ship_scene.gd"

var storying: bool = false:
	set(v):
		storying = v
		if storying:
			Engine.time_scale = 1
		else:
			Engine.time_scale = Config.game_speed

@onready var deadlock_timer: Timer = $DeadlockTimer
@onready var big_burger: Boss = $Units/Enemies/BigBurger
@onready var cola: Boss = $Units/Enemies/Cola
@onready var fries: CharacterBody2D = $Units/Enemies/Fries
@onready var left_moving_platform: StaticBody2D = $Units/Railway/LeftMovingPlatform
@onready var right_moving_platform: StaticBody2D = $Units/Railway2/RightMovingPlatform
@onready var left_fix_collision: CollisionShape2D = $Units/FixWall/LeftFixCollision
@onready var right_fix_collision: CollisionShape2D = $Units/FixWall/RightFixCollision
@onready var player_checker: Area2D = $Units/PlayerChecker
@onready var big_burger_npc: CharacterBody2D = $Units/BigBurgerNpc
@onready var fries_npc: Npc = $Units/FriesNpc
@onready var cola_npc: Npc = $Units/ColaNpc
@onready var scanner: CharacterBody2D = $Units/Scanner

func _before_ready() -> void:
	super()
	big_burger.hide()
	cola.hide()
	fries.hide()
	if explore_status == Constant.ExploreStatus.COMPLETE:
		player_checker.queue_free()
		big_burger.queue_free()
		cola.queue_free()
		fries.queue_free()
		left_fix_collision.queue_free()
		right_fix_collision.queue_free()
		scanner.queue_free()
		big_burger_npc.dialog.root_dialog = big_burger_npc.end_dialog
		fries_npc.dialog.root_dialog = fries_npc.end_dialog

func _input(event: InputEvent) -> void:
	if storying and player.alive:
		if event.is_action_pressed("ui_accept"):
			Engine.time_scale = 4
		elif event.is_action_released("ui_accept"):
			Engine.time_scale = 1

func _story_start() -> void:
	storying = true
	player_checker.queue_free()
	scanner.collision_shape_2d.set_deferred("disabled", true)
	left_moving_platform.open()
	right_moving_platform.open()
	left_fix_collision.set_deferred("disabled", false)
	right_fix_collision.set_deferred("disabled", false)
	InputManager.disabled = true
	player.velocity.x = 0
	big_burger_npc.direction = Constant.Direction.RIGHT
	await UIManager.special_effect.movie_in(1)
	if not cola_npc.dialog.disabled:
		cola_npc.dialog.disabled = true
	fries_npc.animation_play("stand")
	await get_tree().create_timer(0.3).timeout
	big_burger_npc.dialog.root_dialog = big_burger_npc.battle_dialog
	big_burger_npc.dialog.disabled = false


func _on_cola_combo_attack() -> void:
	big_burger.attack_signal = true
	fries.attack_signal = true


func _on_fries_combo_attack() -> void:
	big_burger.attack_signal = true
	cola.attack_signal = true


func _on_big_burger_combo_attack() -> void:
	cola.attack_signal = true
	fries.attack_signal = true


func _on_deadlock_timer_timeout() -> void:
	deadlock_timer.start()
	# 防止死锁
	if ((big_burger.waiting_signal or big_burger.is_dead())
		and (cola.waiting_signal or cola.is_dead())
		and (fries.waiting_signal or fries.is_dead())):
		big_burger.attack_signal = true
		cola.attack_signal = true
		fries.attack_signal = true

func _battle_end() -> void:
	# 检查是否所有Boss都已被击败
	if (big_burger.status.health > 0
		or cola.status.health > 0
		or fries.status.health > 0):
		return
	Achievement.set_achievement(Achievement.ID.DEFEAT_COMBO)
	storying = true
	InputManager.disabled = true
	player.hurt_timer.stop()
	player.reset_flash()
	player.hurtbox.disabled = true
	SoundManager.play_bgm(bgm)
	deadlock_timer.stop()
	await UIManager.special_effect.movie_in(1)
	await get_tree().create_timer(1).timeout
	left_fix_collision.set_deferred("disabled", true)
	right_fix_collision.set_deferred("disabled", true)
	UIManager.status_panel.boss_health_bar_container.hide()
	player.status.health = player.status.max_health
	player.status.potion = player.status.max_potion
	await UIManager.special_effect.movie_out(1)
	InputManager.disabled = false
	storying = false
	left_moving_platform.close()
	right_moving_platform.close()
	explore_status = Constant.ExploreStatus.COMPLETE



func _on_cola_defeated() -> void:
	fries.battle_stage += 1
	big_burger.battle_stage += 1
	_battle_end()


func _on_fries_defeated() -> void:
	cola.battle_stage += 1
	big_burger.battle_stage += 1
	_battle_end()


func _on_big_burger_defeated() -> void:
	cola.battle_stage += 1
	fries.battle_stage += 1
	_battle_end()


func _on_cola_health_changed() -> void:
	UIManager.status_panel.update_boss_health((
		big_burger.status.health + cola.status.health + fries.status.health
	), (
		big_burger.status.max_health + cola.status.max_health + fries.status.max_health
	))


func _on_fries_health_changed() -> void:
	UIManager.status_panel.update_boss_health((
		big_burger.status.health + cola.status.health + fries.status.health
	), (
		big_burger.status.max_health + cola.status.max_health + fries.status.max_health
	))



func _on_big_burger_health_changed() -> void:
	UIManager.status_panel.update_boss_health((
		big_burger.status.health + cola.status.health + fries.status.health
	), (
		big_burger.status.max_health + cola.status.max_health + fries.status.max_health
	))


func _on_player_checker_body_entered(body: Node2D) -> void:
	if not body is Player:
		return
	cola_npc.dialog.root_dialog = cola_npc.battle_dialog
	cola_npc.dialog.disabled = false
	_story_start()


func _on_scanner_updated(context: String) -> void:
	if context != "end":
		return
	_story_start()


func _on_big_burger_npc_updated(context: String) -> void:
	if context != "battle":
		return
	big_burger.direction = big_burger_npc.direction
	big_burger.global_position = big_burger_npc.global_position
	big_burger.show()
	big_burger_npc.hide()
	big_burger_npc.global_position = object_pool.global_position
	fries.direction = fries_npc.direction
	fries.global_position = fries_npc.global_position
	fries.show()
	fries_npc.hide()
	fries_npc.global_position = object_pool.global_position
	cola.direction = cola_npc.direction
	cola.global_position = cola_npc.global_position
	cola.show()
	cola_npc.hide()
	cola_npc.global_position = object_pool.global_position
	UIManager.status_panel.update_boss_health(
		big_burger.status.health + cola.status.health + fries.status.health,
		big_burger.status.max_health + cola.status.max_health + fries.status.max_health)
	UIManager.status_panel.boss_health_bar_container.show()
	await UIManager.special_effect.movie_out(1)
	SoundManager.play_bgm(preload("res://asset/music/boss_late.ogg"))
	InputManager.disabled = false
	deadlock_timer.start()
	big_burger.start_battle()
	cola.start_battle()
	fries.start_battle()
	storying = false
