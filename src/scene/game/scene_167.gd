extends "res://src/scene/game/base/desert_scene.gd"

signal dash_ended

@onready var ham: Boss = $Units/Enemies/Ham
@onready var special_hint_line: Line2D = $Units/SpecialHintLine
@onready var ham_npc: CharacterBody2D = $Units/HamNpc
@onready var player_checker: Area2D = $Units/PlayerChecker
@onready var skewer: CharacterBody2D = $Units/ObjectPool/Skewer
@onready var skewer_2: CharacterBody2D = $Units/ObjectPool/Skewer2
@onready var breakable_object: TileMapLayer = $Units/BreakableObject

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
	ham.hide()
	special_hint_line.hide()
	skewer.behavior_tree.disabled = true
	skewer.hurtbox.disabled = true
	skewer_2.behavior_tree.disabled = true
	skewer_2.hurtbox.disabled = true
	if explore_status == Constant.ExploreStatus.COMPLETE:
		player_checker.queue_free()
		ham.queue_free()
		ham_npc.queue_free()
		skewer.queue_free()
		skewer_2.queue_free()
		breakable_object.queue_free()

func _input(event: InputEvent) -> void:
	if storying and player.alive:
		if event.is_action_pressed("ui_accept"):
			Engine.time_scale = 4
		elif event.is_action_released("ui_accept"):
			Engine.time_scale = 1

func _physics_process(_delta: float) -> void:
	match story_stage:
		0:
			if ham.velocity.is_zero_approx():
				ham.velocity = Vector2.ZERO
				ham.attack_direction = (Vector2(336, 208) - ham.hint_line.global_position).normalized()
				ham.velocity = ham.attack_direction * 600
				ham.play_direction_animation(true)
				SoundManager.play_sfx("HamAttack")
				story_stage = 1
				return
		1:
			if ham.global_position.y >= 160:
				breakable_object.dead()
				story_stage = 2
				return
		2:
			if ham.velocity.is_zero_approx():
				ham.attack_direction = Vector2.RIGHT
				ham.velocity = ham.attack_direction * 600
				ham.play_direction_animation(true)
				SoundManager.play_sfx("HamAttack")
				story_stage = 3
				return
		3:
			if ham.velocity.is_zero_approx():
				ham.velocity = Vector2.ZERO
				ham.queue_free()
				dash_ended.emit()
				story_stage = -1
				return


func _on_player_checker_body_entered(body: Node2D) -> void:
	if not body is Player:
		return
	player_checker.queue_free()
	player.velocity.x = 0
	InputManager.disabled = true
	storying = true
	await UIManager.special_effect.movie_in(1)
	skewer_2.direction = Constant.Direction.LEFT
	ham_npc.dialog.disabled = false

func _on_ham_npc_updated(context: String) -> void:
	match context:
		"throw":
			ham_npc.animation_play("throw")
			await get_tree().create_timer(0.3).timeout
			var bullet: CharacterBullet = Game.get_object("charcoal_bullet")
			if bullet != null:
				var velocity_x: float = Util.calculate_x_velocity_parabola(
					ham_npc.throw_point.global_position,
					player.global_position,
					-420,
					Constant.gravity)
				bullet.spawn(
					ham_npc.throw_point.global_position,
					Vector2(velocity_x, -420))
			ham_npc.animation_player.animation_finished.connect(_throw_story, CONNECT_ONE_SHOT)
		"battle":
			ham_npc.animation_play("ready")
			ham_npc.animation_player.animation_finished.connect(_start_battle, CONNECT_ONE_SHOT)

func _throw_story(anim_name: String) -> void:
	if anim_name != "throw":
		return
	await get_tree().create_timer(0.1).timeout
	ham_npc.animation_play("idle")
	await get_tree().create_timer(0.5).timeout
	player.state_machine.disabled = true
	player.animation_play("run")
	player.velocity.x = -120
	player.face_direction = Constant.Direction.LEFT
	await get_tree().create_timer(0.2).timeout
	player.velocity.x = 0
	player.animation_play("idle")
	player.state_machine.disabled = false
	player.face_direction = Constant.Direction.RIGHT
	await get_tree().create_timer(2.5).timeout
	ham_npc.dialog.disabled = false

func _start_battle(anim_name: String) -> void:
	if anim_name != "ready":
		return
	ham.direction = Constant.Direction.LEFT
	ham.global_position = ham_npc.global_position
	ham.show()
	ham_npc.hide()
	ham_npc.global_position = object_pool.global_position
	skewer.hurtbox.disabled = false
	skewer_2.hurtbox.disabled = false
	UIManager.status_panel.update_boss_health(ham.status.health, ham.status.max_health)
	UIManager.status_panel.boss_health_bar_container.show()
	await UIManager.special_effect.movie_out(1)
	SoundManager.play_bgm(preload("res://asset/music/boss_middle.ogg"))
	ham.start_battle()
	skewer.behavior_tree.disabled = false
	skewer_2.behavior_tree.disabled = false
	InputManager.disabled = false
	storying = false


func _on_ham_defeated() -> void:
	Achievement.set_achievement(Achievement.ID.DEFEAT_HAM)
	special_hint_line.hide()
	storying = true
	player.hurt_timer.stop()
	player.reset_flash.call_deferred()
	player.hurtbox.disabled = true
	SoundManager.play_bgm(bgm)
	InputManager.disabled = true
	UIManager.status_panel.boss_health_bar_container.hide()
	ham.gravity = Constant.gravity
	ham.animation_play("hurt")
	await UIManager.special_effect.movie_in(1)
	await get_tree().create_timer(0.5).timeout
	ham.gravity = 0
	ham.attack_direction = (Vector2(328, 48) - ham.hint_line.global_position).normalized()
	ham.velocity = ham.attack_direction * 600
	ham.trail_particle.emitting = true
	ham.play_direction_animation(true)
	SoundManager.play_sfx("HamAttack")
	story_stage = 0
	


func _on_dash_ended() -> void:
	# 恢复玩家状态
	player.status.health = player.status.max_health
	player.status.potion = player.status.max_potion
	UIManager.status_panel.boss_health_bar_container.hide()
	await get_tree().create_timer(1).timeout
	await UIManager.special_effect.movie_out(1)
	player.hurtbox.disabled = false
	InputManager.disabled = false
	storying = false
	explore_status = Constant.ExploreStatus.COMPLETE
