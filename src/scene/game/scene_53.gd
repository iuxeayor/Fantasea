extends "res://src/scene/game/base/island_scene.gd"

signal peanut_butter_landed

var storying: bool = false:
	set(v):
		storying = v
		set_physics_process(storying)
		if storying:
			Engine.time_scale = 1
		else:
			Engine.time_scale = Config.game_speed

var land_y: float = 0
var left_edge: float = 0
var right_edge: float = 0

var is_peanut_butter_moving: bool = false

@onready var peanut_butter: Boss = $Units/Enemies/PeanutButter
@onready var peanut_butter_npc: CharacterBody2D = $Units/PeanutButterNpc

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var spoon_bullet: CharacterBullet = $Units/SpoonBullet

@onready var left_point: Marker2D = $Units/Markers/LeftPoint
@onready var mid_point: Marker2D = $Units/Markers/MidPoint
@onready var right_point: Marker2D = $Units/Markers/RightPoint

@onready var warn_light: PointLight2D = $Lights/WarnLight
@onready var warn_timer: Timer = $Lights/WarnLight/WarnTimer

@onready var npc_point: Marker2D = $Units/Markers/NpcPoint

func _before_ready() -> void:
	super ()
	set_physics_process(false)
	land_y = left_point.global_position.y
	left_edge = left_point.global_position.x - 16
	right_edge = right_point.global_position.x + 16
	spoon_bullet.hide()
	warn_light.hide()
	peanut_butter.hide()
	if explore_status == Constant.ExploreStatus.COMPLETE:
		# 删除探索单位
		peanut_butter.queue_free()
		spoon_bullet.queue_free()
		# 处理Npc状态
		peanut_butter_npc.animation_play("idle")
		peanut_butter_npc.global_position = npc_point.global_position
		peanut_butter_npc.dialog.root_dialog = peanut_butter_npc.normal_dialog
		peanut_butter_npc.turn = true

func _physics_process(_delta: float) -> void:
	if is_peanut_butter_moving:
		if peanut_butter.velocity.y == 0 and peanut_butter.is_on_floor():
			peanut_butter.velocity = Vector2.ZERO
			peanut_butter_landed.emit()
			is_peanut_butter_moving = false
	

func _input(event: InputEvent) -> void:
	if storying and player.alive:
		if event.is_action_pressed("ui_accept"):
			Engine.time_scale = 4
		elif event.is_action_released("ui_accept"):
			Engine.time_scale = 1

func show_warning(left_x: float, right_x: float) -> void:
	# 显示警告灯
	warn_light.hide()
	warn_light.global_position.x = left_x + (right_x - left_x) / 2
	warn_light.scale.x = (right_x - left_x) / 8
	await get_tree().process_frame
	warn_light.show.call_deferred()
	warn_timer.start()

func _on_peanut_butter_npc_updated(context: String) -> void:
	match context:
		"fight":
			_story_fight()
		"defeated":
			_story_defeated()
	

func _on_peanut_butter_defeated() -> void:
	Achievement.set_achievement(Achievement.ID.DEFEAT_PEANUT_BUTTER)
	SoundManager.play_bgm(bgm)
	storying = true
	InputManager.disabled = true
	# 移除玩家碰撞
	player.hurt_timer.stop()
	player.reset_flash.call_deferred()
	player.hurtbox.disabled = true
	# 故事
	peanut_butter.velocity = Vector2.ZERO
	peanut_butter.animation_play("idle")
	await UIManager.special_effect.movie_in(1)
	# 跳到右侧
	peanut_butter.animation_play("jump")
	peanut_butter.direction = Constant.Direction.RIGHT
	peanut_butter.velocity = Vector2(Util.calculate_x_velocity_parabola(
		peanut_butter.global_position,
		right_point.global_position,
		-220,
		Constant.gravity
	), -220)
	is_peanut_butter_moving = true
	await peanut_butter_landed
	peanut_butter.animation_play("idle")
	peanut_butter.direction = Constant.Direction.LEFT
	peanut_butter_npc.global_position = peanut_butter.global_position
	peanut_butter_npc.show.call_deferred()
	peanut_butter.queue_free()
	# 对话
	peanut_butter_npc.dialog.root_dialog = peanut_butter_npc.defeated_dialog
	peanut_butter_npc.dialog.disabled = false
	
func _story_fight() -> void:
	storying = true
	InputManager.disabled = true
	# boss准备
	await UIManager.special_effect.movie_in(1)
	peanut_butter.global_position = peanut_butter_npc.global_position
	await get_tree().create_timer(0.5).timeout
	peanut_butter.direction = peanut_butter_npc.direction
	peanut_butter.animation_play("idle")
	peanut_butter.show.call_deferred()
	peanut_butter_npc.hide.call_deferred()
	peanut_butter_npc.global_position = Vector2.ZERO
	# 跳向远离玩家的位置
	peanut_butter.trail.reset()
	peanut_butter.animation_play("jump")
	var target_position: Vector2 = left_point.global_position
	if player.global_position.x < mid_point.global_position.x:
		target_position = right_point.global_position
		peanut_butter.direction = Constant.Direction.RIGHT
	else:
		target_position = left_point.global_position
		peanut_butter.direction = Constant.Direction.LEFT
	var velo_y: float = -220
	peanut_butter.velocity = Vector2(Util.calculate_x_velocity_parabola(
		peanut_butter.global_position,
		target_position,
		velo_y,
		Constant.gravity
	), velo_y)
	is_peanut_butter_moving = true
	await peanut_butter_landed
	# 面向玩家
	peanut_butter.animation_play("idle")
	if peanut_butter.global_position.x < player.global_position.x:
		peanut_butter.direction = Constant.Direction.RIGHT
	else:
		peanut_butter.direction = Constant.Direction.LEFT
	# 准备战斗
	UIManager.status_panel.update_boss_health(peanut_butter.status.health, peanut_butter.status.max_health)
	UIManager.status_panel.boss_health_bar_container.show()
	await get_tree().create_timer(1).timeout
	await UIManager.special_effect.movie_out(1)
	storying = false
	# 开始战斗
	peanut_butter.start_battle()
	SoundManager.play_bgm(preload("res://asset/music/boss_early.ogg"))
	InputManager.disabled = false

func _story_defeated() -> void:
	peanut_butter_npc.animation_play("relax")
	await peanut_butter_npc.animation_player.animation_finished
	UIManager.status_panel.boss_health_bar_container.hide()
	# 恢复玩家状态
	player.status.health = player.status.max_health
	player.status.potion = player.status.max_potion
	await UIManager.special_effect.movie_out(1)
	# 结束
	explore_status = Constant.ExploreStatus.COMPLETE
	storying = false
	InputManager.disabled = false
	player.hurtbox.disabled = false

func _on_warn_timer_timeout() -> void:
	warn_light.hide()
