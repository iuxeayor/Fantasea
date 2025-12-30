extends "res://src/scene/game/base/desert_scene.gd"

const LEAVE_POSITION: Vector2 = Vector2(-16, 168)

@onready var butter: Boss = $Units/Enemies/Butter
@onready var butter_npc: CharacterBody2D = $Units/ButterNpc
@onready var attack_line: Line2D = $Units/AttackLine
@onready var player_checker: Area2D = $Units/PlayerChecker
@onready var wall: StaticBody2D = $Units/Wall
@onready var entry_moving_platform: StaticBody2D = $Units/EntryMovingPlatform
@onready var exit_moving_platform: StaticBody2D = $Units/ExitMovingPlatform

var storying: bool = false:
	set(v):
		storying = v
		if storying:
			Engine.time_scale = 1
		else:
			Engine.time_scale = Config.game_speed

var land_y: float = 176
var sky_y: float = 48
var left_x: float = 40
var right_x: float = 344
var mid_left_x: float = 96
var mid_x: float = 192
var mid_right_x: float = 288


func _before_ready() -> void:
	super ()
	butter.hide()
	butter_npc.collision_shape_2d.set_deferred("disabled", true)
	if explore_status == Constant.ExploreStatus.COMPLETE:
		butter.queue_free()
		player_checker.queue_free()
		butter_npc.queue_free()
		wall.queue_free()

func _input(event: InputEvent) -> void:
	if storying and player.alive:
		if event.is_action_pressed("ui_accept"):
			Engine.time_scale = 4
		elif event.is_action_released("ui_accept"):
			Engine.time_scale = 1

func line_aim(start: Vector2, end: Vector2) -> void:
	attack_line.points[0] = attack_line.to_local(start)
	attack_line.points[1] = attack_line.to_local(end)
	attack_line.width = 0
	attack_line.show()
	SoundManager.play_sfx("ButterAim")
	var tween: Tween = create_tween()
	tween.tween_property(attack_line, "width", 1, 0.05)
	await tween.finished
	await get_tree().create_timer(0.1).timeout
	var tween2: Tween = create_tween()
	tween2.tween_property(attack_line, "width", 0, 0.1)
	await tween2.finished
	attack_line.hide()
	attack_line.width = 0


func _on_player_checker_body_entered(body: Node2D) -> void:
	if not body is Player:
		return
	player_checker.queue_free()
	storying = true
	InputManager.disabled = true
	entry_moving_platform.open()
	await UIManager.special_effect.movie_in(1)
	butter_npc.direction = Constant.Direction.RIGHT
	await get_tree().create_timer(0.5).timeout
	butter_npc.dialog.disabled = false

func _on_butter_npc_updated(context: String) -> void:
	match context:
		"combat":
			_story_combat()
		"defeat":
			_story_defeat()
		"end":
			_story_end()

func _story_combat() -> void:
	UIManager.status_panel.update_boss_health(butter.status.health, butter.status.max_health)
	UIManager.status_panel.boss_health_bar_container.show()
	butter.global_position = butter_npc.global_position
	butter.direction = Constant.Direction.RIGHT
	butter.show()
	butter_npc.hide()
	butter_npc.global_position = Vector2.ZERO
	await get_tree().create_timer(0.5).timeout
	await UIManager.special_effect.movie_out(1)
	SoundManager.play_bgm(preload("res://asset/music/boss_middle.ogg"))
	butter.start_battle()
	InputManager.disabled = false
	storying = false

func _story_defeat() -> void:
	UIManager.status_panel.boss_health_bar_container.hide()
	entry_moving_platform.close()
	exit_moving_platform.open()
	wall.queue_free()
	await get_tree().create_timer(1).timeout
	butter_npc.direction = Constant.Direction.LEFT
	await get_tree().create_timer(1).timeout
	butter_npc.direction = Constant.Direction.RIGHT
	await get_tree().create_timer(1).timeout
	butter_npc.direction = Constant.Direction.LEFT
	await get_tree().create_timer(1).timeout
	butter_npc.dialog.root_dialog = butter_npc.end_dialog
	butter_npc.dialog.disabled = false

func _story_end() -> void:
	butter_npc.animation_play("walk")
	var walk_time: float = butter_npc.global_position.distance_to(LEAVE_POSITION) / 100
	var tween: Tween = create_tween()
	tween.tween_property(butter_npc, "global_position", LEAVE_POSITION, walk_time)
	tween.finished.connect(_story_tween_end, CONNECT_ONE_SHOT)

func _story_tween_end() -> void:
	await get_tree().create_timer(1).timeout
	# 恢复玩家状态
	player.status.health = player.status.max_health
	player.status.potion = player.status.max_potion
	await UIManager.special_effect.movie_out(1)
	explore_status = Constant.ExploreStatus.COMPLETE
	player.hurtbox.disabled = false
	InputManager.disabled = false
	storying = false

func _on_butter_defeated() -> void:
	Achievement.set_achievement(Achievement.ID.DEFEAT_BUTTER)
	SoundManager.play_bgm(bgm)
	storying = true
	InputManager.disabled = true
	# 移除玩家碰撞
	player.hurt_timer.stop()
	player.reset_flash.call_deferred()
	player.hurtbox.disabled = true
	# 停止行为
	butter.stop_battle()
	butter.animation_play("hurt")
	await UIManager.special_effect.movie_in(1)
	butter.animation_play("idle")
	# 面向玩家
	if butter.global_position.x > player.global_position.x:
		butter.direction = Constant.Direction.LEFT
	else:
		butter.direction = Constant.Direction.RIGHT
	butter_npc.global_position = butter.global_position
	butter_npc.direction = butter.direction
	butter_npc.show()
	butter.queue_free()
	butter_npc.dialog.root_dialog = butter_npc.defeat_dialog
	butter_npc.dialog.disabled = false
	
