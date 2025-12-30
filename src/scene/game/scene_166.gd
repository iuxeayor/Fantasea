extends "res://src/scene/game/base/forest_scene.gd"

const LEFT_X: float = 40
const END_POSITION: Vector2 = Vector2(288, 184)
const DEFEAT_JUMP_VELOCITY: float = -400
const RND_ROOT_Y: float = 204

@onready var big_mushroom: Boss = $Units/Enemies/BigMushroom
@onready var crab_stick: CharacterBody2D = $Background/Prop/CrabStick
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var player_checker: Area2D = $Units/PlayerChecker
@onready var big_mushroom_npc: Npc = $BigMushroomNpc
@onready var sleep_particle: GPUParticles2D = $Units/SleepParticle
@onready var stun_timer: Timer = $StunTimer

var storying: bool = false:
	set(v):
		storying = v
		set_physics_process(storying)
		if storying:
			Engine.time_scale = 1
		else:
			Engine.time_scale = Config.game_speed
var story_stage: int = -1


func _before_ready() -> void:
	super()
	set_physics_process(false)
	big_mushroom.hide()
	if explore_status == Constant.ExploreStatus.COMPLETE:
		player_checker.queue_free()
		big_mushroom.queue_free()
		crab_stick.dialog.root_dialog = crab_stick.boss_dialog

func _input(event: InputEvent) -> void:
	if storying and player.alive:
		if event.is_action_pressed("ui_accept"):
			Engine.time_scale = 4
		elif event.is_action_released("ui_accept"):
			Engine.time_scale = 1

func _physics_process(delta: float) -> void:
	match story_stage:
		0: # 等待落地到达终点
			if big_mushroom.velocity.y == 0 and big_mushroom.is_on_floor():
				big_mushroom.velocity = Vector2.ZERO
				big_mushroom.animation_play("stun")
				stun_timer.start()
				big_mushroom.sprite_2d.rotation = 0
				big_mushroom.land_particle.restart()
				big_mushroom.land_particle_2.restart()
				Game.get_game_scene().game_camera.shake(2, 0.4)
				SoundManager.play_sfx("BigMushroomLand")
				story_stage = -1
				return
			big_mushroom.sprite_2d.rotation += PI * 2 * big_mushroom.direction * delta

func _on_player_checker_body_entered(body: Node2D) -> void:
	if not body is Player:
		return
	crab_stick.collision_shape_2d.set_deferred("disabled", true)
	player_checker.queue_free()
	player.velocity.x = 0
	InputManager.disabled = true
	storying = true
	sleep_particle.emitting = false
	await UIManager.special_effect.movie_in(1)
	await get_tree().create_timer(1).timeout
	animation_player.play("wake")
	animation_player.animation_finished.connect(_wake_story)

func _wake_story(animation_name: String) -> void:
	if animation_name != "wake":
		return
	big_mushroom_npc.animation_play("stand")
	await get_tree().create_timer(big_mushroom_npc.animation_player.get_animation("stand").length).timeout
	big_mushroom.direction = big_mushroom_npc.direction
	big_mushroom.global_position = big_mushroom_npc.global_position
	big_mushroom.show()
	big_mushroom_npc.hide()
	big_mushroom_npc.global_position = units.global_position
	UIManager.status_panel.update_boss_health(
		big_mushroom.status.health,
		big_mushroom.status.max_health)
	UIManager.status_panel.boss_health_bar_container.show()
	await get_tree().create_timer(1).timeout
	await UIManager.special_effect.movie_out(1)
	storying = false
	InputManager.disabled = false
	big_mushroom.start_battle()
	SoundManager.play_bgm(preload("res://asset/music/boss_early.ogg"))

func _on_big_mushroom_defeated() -> void:
	Achievement.set_achievement(Achievement.ID.DEFEAT_BIG_MUSHROOM)
	storying = true
	player.hurt_timer.stop()
	player.reset_flash.call_deferred()
	player.hurtbox.disabled = true
	SoundManager.play_bgm(bgm)
	InputManager.disabled = true
	UIManager.status_panel.boss_health_bar_container.hide()
	UIManager.special_effect.movie_in(1)
	if big_mushroom.global_position.x < END_POSITION.x:
		big_mushroom.direction = Constant.Direction.RIGHT
	else:
		big_mushroom.direction = Constant.Direction.LEFT
	big_mushroom.animation_play("roll")
	big_mushroom.sprite_2d.rotation = 0
	var velocity_x: float = Util.calculate_x_velocity_parabola(
		big_mushroom.global_position,
		END_POSITION,
		DEFEAT_JUMP_VELOCITY,
		Constant.gravity)
	big_mushroom.velocity = Vector2(velocity_x, DEFEAT_JUMP_VELOCITY)
	story_stage = 0


func _on_stun_timer_timeout() -> void:
	big_mushroom_npc.direction = big_mushroom.direction
	big_mushroom_npc.global_position = big_mushroom.global_position
	big_mushroom_npc.show()
	big_mushroom.hide()
	big_mushroom.global_position = object_pool.global_position
	big_mushroom_npc.animation_play("defeat")
	big_mushroom_npc.animation_player.animation_finished.connect(_end)

func _end(animation_name: String) -> void:
	if animation_name != "defeat":
		return
	var tween: Tween = create_tween()
	tween.tween_property(big_mushroom_npc, "global_position:y", RND_ROOT_Y, 1)
	tween.finished.connect(_end_tween_finished, CONNECT_ONE_SHOT)

func _end_tween_finished() -> void:
	await get_tree().create_timer(2).timeout
	crab_stick.dialog.root_dialog = crab_stick.boss_dialog
	crab_stick.collision_shape_2d.set_deferred("disabled", false)
	# 恢复玩家状态
	player.status.health = player.status.max_health
	player.status.potion = player.status.max_potion
	await UIManager.special_effect.movie_out(1)
	player.hurtbox.disabled = false
	InputManager.disabled = false
	storying = false
	explore_status = Constant.ExploreStatus.COMPLETE
