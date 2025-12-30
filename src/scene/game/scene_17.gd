extends "res://src/scene/game/base/forest_scene.gd"

signal story_stage_changed
signal player_landed

var storying: bool = false:
	set(v):
		storying = v
		set_physics_process(storying)
		if storying:
			Engine.time_scale = 1
		else:
			Engine.time_scale = Config.game_speed

var waiting_player_land: bool = false

var story_stage: int = -1 # 无法用动画处理的剧情阶段，使用类似状态机的方式处理

@onready var watermelon: Boss = $Units/Enemies/Watermelon
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var jump_target_point: Marker2D = $JumpTargetPoint
@onready var player_checker: Area2D = $PlayerChecker
@onready var end_block: TileMapLayer = $Units/EndBlock


func _before_ready() -> void:
	super ()
	set_physics_process(false)
	watermelon.behavior_tree.disabled = true
	if explore_status == Constant.ExploreStatus.COMPLETE:
		watermelon.queue_free()
		end_block.queue_free()
		player_checker.queue_free()

func _physics_process(_delta: float) -> void:
	match story_stage:
		0:
			if (watermelon.is_on_floor()
				and watermelon.velocity.y == 0
				and watermelon.global_position.y > jump_target_point.global_position.y - 8):
				watermelon.velocity = Vector2.ZERO
				game_camera.shake(1, 0.5)
				SoundManager.play_sfx("WatermelonHitWall")
				story_stage = -1
				story_stage_changed.emit()
		1:
			# 撞墙后往左
			if (watermelon.is_on_wall()
				and watermelon.velocity.x == 0):
				watermelon.velocity.x = -320
				watermelon.direction = Constant.Direction.LEFT
				watermelon.hit_wall_particle.restart()
				game_camera.shake(1, 0.1)
				SoundManager.play_sfx("WatermelonHitWall")
				story_stage = 2
		2:
			# 撞墙后动画接管
			if (watermelon.is_on_wall()
				and watermelon.velocity.x == 0):
				watermelon.direction = Constant.Direction.RIGHT
				watermelon.hit_wall_particle.restart()
				watermelon.velocity = Vector2.ZERO
				game_camera.shake(1, 0.1)
				SoundManager.play_sfx("WatermelonHitWall")
				story_stage = -1
				story_stage_changed.emit()
	if waiting_player_land:
		if (player.is_on_floor()
			and player.velocity.y == 0):
			waiting_player_land = false
			player_landed.emit()

func play_boss_fall() -> void:
	watermelon.animation_play("fall")

func play_boss_idle() -> void:
	watermelon.animation_play("idle")

func animation_remove_broken_wall() -> void:
	end_block.dead()
	game_camera.shake(1, 0.6)


func _input(event: InputEvent) -> void:
	if storying and player.alive:
		if event.is_action_pressed("ui_accept"):
			Engine.time_scale = 4
		elif event.is_action_released("ui_accept"):
			Engine.time_scale = 1

func _on_player_checker_body_entered(body: Node2D) -> void:
	if not body is Player:
		return
	player_checker.queue_free()
	InputManager.disabled = true
	storying = true
	await UIManager.special_effect.movie_in(1)
	# 检测玩家是否落地
	waiting_player_land = true
	await player_landed
	# 西瓜滚动入场
	await get_tree().create_timer(1).timeout
	SoundManager.play_sfx("WatermelonRollLoop")
	await get_tree().create_timer(1).timeout
	watermelon.animation_play("roll")
	animation_player.play("boss_roll_to_jump_point")
	await animation_player.animation_finished
	SoundManager.stop_sfx("WatermelonRollLoop")
	SoundManager.play_sfx("WatermelonJump")
	# 此处无法使用动画，使用行为树处理
	watermelon.velocity.y = -200
	watermelon.velocity.x = Util.calculate_x_velocity_parabola(
		watermelon.global_position,
		jump_target_point.global_position,
		watermelon.velocity.y,
		watermelon.gravity)
	story_stage = 0
	await story_stage_changed
	SoundManager.play_sfx("WatermelonLand")
	# 跳跃和转换状态动作
	animation_player.play("boss_jump_and_trans")
	await animation_player.animation_finished
	await get_tree().create_timer(1).timeout
	UIManager.status_panel.update_boss_health(watermelon.status.health, watermelon.status.max_health)
	UIManager.status_panel.boss_health_bar_container.show()
	await UIManager.special_effect.movie_out(1)
	SoundManager.play_bgm(preload("res://asset/music/boss_early.ogg"))
	# 恢复游戏中
	InputManager.disabled = false
	watermelon.start_battle()
	storying = false


func _on_watermelon_defeated() -> void:
	Achievement.set_achievement(Achievement.ID.DEFEAT_WATERMELON)
	storying = true
	SoundManager.play_bgm(bgm)
	SoundManager.play_sfx("WatermelonRollLoop")
	# 移除玩家碰撞
	player.hurt_timer.stop()
	player.reset_flash.call_deferred()
	player.hurtbox.disabled = true
	UIManager.special_effect.movie_in(1)
	UIManager.status_panel.boss_health_bar_container.hide()
	InputManager.disabled = true
	watermelon.animation_play("roll")
	# 1：往右滚，撞墙后往左
	if watermelon.global_position.x > player.global_position.x:
		watermelon.direction = Constant.Direction.RIGHT
		watermelon.velocity.x = 320
		story_stage = 1
	# 2：往左滚，撞墙后往右
	else:
		watermelon.velocity.x = -320
		watermelon.direction = Constant.Direction.LEFT
		story_stage = 2
	await story_stage_changed
	animation_player.play("boss_defeat")
	await animation_player.animation_finished
	await get_tree().create_timer(1.5).timeout
	SoundManager.stop_sfx("WatermelonRollLoop")
	SoundManager.play_sfx("WatermelonHitWall")
	game_camera.shake(1, 0.1)
	await get_tree().create_timer(1).timeout
	# 恢复玩家状态
	player.status.health = player.status.max_health
	player.status.potion = player.status.max_potion
	await UIManager.special_effect.movie_out(1)
	InputManager.disabled = false
	storying = false
	explore_status = Constant.ExploreStatus.COMPLETE
