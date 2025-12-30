extends "res://src/scene/game/base/snowfield_scene.gd"

const CAMERA_LEFT: int = 768
const GROUND_Y: float = 168
const SKY_Y: float = 64
const LEFT_X: float = 800
const RIGHT_X: float = 1120
const MID_X: float = 960
const LEFT_POINT: Vector2 = Vector2(LEFT_X, GROUND_Y)
const RIGHT_POINT: Vector2 = Vector2(RIGHT_X, GROUND_Y)
const LEFT_PLATFORM_POINT: Vector2 = Vector2(LEFT_X, SKY_Y)
const RIGHT_PLATFORM_POINT: Vector2 = Vector2(RIGHT_X, SKY_Y)
const FAKE_DOWN_Y: float = 136

signal story_end

var storying: bool = false:
	set(v):
		storying = v
		set_physics_process(storying)
		if storying:
			Engine.time_scale = 1
		else:
			Engine.time_scale = Config.game_speed
var story_stage: int = -1

var waiting_player_land: bool = false ## 开始等待玩家落地

var aiming_bullet: Array[Node2D] = []
	
@onready var player_checker: Area2D = $Units/PlayerChecker
@onready var california_roll: Boss = $Units/Enemies/CaliforniaRoll
@onready var left_ice_platform: StaticBody2D = $Units/LeftIcePlatform
@onready var right_ice_platform: StaticBody2D = $Units/RightIcePlatform
@onready var roll_npc: CharacterBody2D = $Units/RollNpc



func _before_ready() -> void:
	super()
	set_physics_process(false)
	california_roll.hide()
	if explore_status == Constant.ExploreStatus.COMPLETE:
		player_checker.queue_free()
		california_roll.queue_free()
		right_ice_platform.queue_free()
		roll_npc.dialog.root_dialog = roll_npc.end_dialog

func _input(event: InputEvent) -> void:
	if storying and player.alive:
		if event.is_action_pressed("ui_accept"):
			Engine.time_scale = 4
		elif event.is_action_released("ui_accept"):
			Engine.time_scale = 1

func _physics_process(_delta: float) -> void:
	match story_stage:
		0:
			# 等待下落
			if california_roll.velocity.y >= 0:
				california_roll.gravity = Constant.gravity * 2
				california_roll.animation_play("down_attack")
				story_stage = 1
				return
		1:
			# 破坏平台
			if california_roll.global_position.y >= SKY_Y:
				right_ice_platform.gpu_particles_2d.restart()
				SoundManager.play_sfx("IcePlatformChange")
				right_ice_platform.sprite_2d.hide()
				right_ice_platform.collision_shape_2d.set_deferred("disabled", true)
				story_stage = 2
				return
		2:
			# 等待落地
			if california_roll.is_on_floor() and is_zero_approx(california_roll.velocity.y):
				california_roll.velocity = Vector2.ZERO
				california_roll.teleport_particle.trigger(california_roll.global_position + Vector2(0, -10))
				california_roll.global_position = Vector2(randf_range(LEFT_X, RIGHT_X), GROUND_Y)
				california_roll.teleport_particle.trigger(california_roll.global_position + Vector2(0, -10))
				if player.global_position.x < california_roll.global_position.x:
					california_roll.direction = Constant.Direction.LEFT
				else:
					california_roll.direction = Constant.Direction.RIGHT
				SoundManager.play_sfx("RollTeleport")
				story_end.emit()
				story_stage = -1
				return
				
func bullet_aim(start: Vector2, target: Vector2) -> void:
	var bullet: Node2D = Game.get_object("bullet_hit")
	if bullet == null:
		return
	bullet.aim(start, target)
	aiming_bullet.append(bullet)


func bullet_shoot() -> void:
	if aiming_bullet.size() == 0:
		return
	var bullet: Node2D = aiming_bullet.pop_front()
	bullet.shoot()

func bullet_reset() -> void:
	for bullet: Node2D in object_pool.pools["bullet_hit"]:
		bullet.reset()
	for bullet: Node2D in aiming_bullet:
		bullet.reset()
	aiming_bullet.clear()

func _on_player_checker_body_entered(body: Node2D) -> void:
	if not body is Player:
		return
	storying = true
	player_checker.queue_free()
	game_camera.limit_left = CAMERA_LEFT
	# 适配移动设备屏幕
	if Util.is_touchscreen_platform():
		var screen_width: int = ProjectSettings.get_setting("display/window/size/viewport_width")
		var screen_height: int = ProjectSettings.get_setting("display/window/size/viewport_height")
		var base_ratio: float = float(screen_width) / float(screen_height)
		var screen_size: Vector2 = get_viewport().get_visible_rect().size
		var screen_ratio: float = screen_size.x / screen_size.y
		if screen_ratio > base_ratio:
			var expand: int = roundi((screen_size.x - screen_size.y * base_ratio) / 2)
			game_camera.limit_left -= expand
	InputManager.disabled = true
	player.velocity.x = 0
	player.state_machine.change_state("AttackSubFSM")
	await UIManager.special_effect.movie_in(1)
	await get_tree().create_timer(1).timeout
	roll_npc.dialog.disabled = false



func _on_roll_npc_updated(context: String) -> void:
	if context != "battle":
		return
	await get_tree().create_timer(0.5).timeout
	roll_npc.animation_play("stand")
	await get_tree().create_timer(0.5).timeout
	california_roll.direction = roll_npc.direction
	california_roll.global_position = roll_npc.global_position
	california_roll.show()
	roll_npc.hide()
	roll_npc.global_position = object_pool.global_position
	await get_tree().create_timer(0.5).timeout
	UIManager.status_panel.update_boss_health(
		california_roll.status.health,
		california_roll.status.max_health)
	UIManager.status_panel.boss_health_bar_container.show()
	await UIManager.special_effect.movie_out(1)
	SoundManager.play_bgm(preload("res://asset/music/boss_late.ogg"))
	InputManager.disabled = false
	california_roll.start_battle()
	storying = false


func _on_california_roll_defeated() -> void:
	Achievement.set_achievement(Achievement.ID.DEFEAT_CALIFORNIA_ROLL)
	storying = true
	InputManager.disabled = true
	SoundManager.play_bgm(bgm)
	bullet_reset()
	# 移除玩家碰撞
	player.hurt_timer.stop()
	player.reset_flash.call_deferred()
	player.hurtbox.disabled = true
	california_roll.animation_play("idle")
	await UIManager.special_effect.movie_in(1)
	california_roll.teleport_particle.trigger(california_roll.global_position + Vector2(0, -10))
	california_roll.global_position = Vector2(RIGHT_X, SKY_Y)
	SoundManager.play_sfx("RollTeleport")
	california_roll.teleport_particle.trigger(california_roll.global_position + Vector2(0, -10))
	california_roll.animation_play("ready_down")
	california_roll.velocity = Vector2(0, -240)
	right_ice_platform.set_collision_layer_value(1, false)
	story_stage = 0
	


func _on_story_end() -> void:
	roll_npc.dialog.root_dialog = roll_npc.end_dialog
	roll_npc.global_position = california_roll.global_position
	roll_npc.direction = california_roll.direction
	roll_npc.show()
	california_roll.hide()
	california_roll.global_position = object_pool.global_position
	await get_tree().create_timer(1).timeout
	roll_npc.animation_play("kneel")
	roll_npc.animation_player.animation_finished.connect(_story_end, CONNECT_ONE_SHOT)
	

func _story_end(anim_name: String) -> void:
	if anim_name != "kneel":
		return
	await get_tree().create_timer(1).timeout
	UIManager.status_panel.boss_health_bar_container.hide()
	# 恢复玩家状态
	player.status.health = player.status.max_health
	player.status.potion = player.status.max_potion
	await UIManager.special_effect.movie_out(1)
	right_ice_platform.queue_free()
	_limit_camera()
	player.hurtbox.disabled = false
	InputManager.disabled = false
	storying = false
	explore_status = Constant.ExploreStatus.COMPLETE
