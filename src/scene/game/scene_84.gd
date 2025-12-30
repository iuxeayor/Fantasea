extends "res://src/scene/game/base/snowfield_scene.gd"

var storying: bool = false:
	set(v):
		storying = v
		set_physics_process(storying)
		if storying:
			Engine.time_scale = 1
		else:
			Engine.time_scale = Config.game_speed
var story_stage: int = -1

signal story_stage_changed

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var ice: Boss = $Units/Enemies/Ice
@onready var ice_npc: Npc = $Units/IceNpc
@onready var icemaker_particle: GPUParticles2D = $Units/Icemaker/IcemakerParticle
@onready var icemaker_switch: Npc = $Units/IcemakerSwitch
@onready var icemaker: Sprite2D = $Units/Icemaker
@onready var breakable_object: TileMapLayer = $Units/BreakableObject

var icemaker_speed: float = 0
var ice_npc_speed: float = 0

func _before_ready() -> void:
	super ()
	set_physics_process(false)
	ice.hide()
	if explore_status == Constant.ExploreStatus.COMPLETE:
		ice.queue_free()
		ice_npc.queue_free()
		icemaker.queue_free()
		breakable_object.queue_free()
		icemaker_switch.collision_shape_2d.disabled = true
	else:
		SoundManager.play_sfx("IcemakerLoop")

func _physics_process(delta: float) -> void:
	match story_stage:
		0:
			ice.velocity.x = move_toward(ice.velocity.x, 140, delta * 140 * 3)
			if (ice.wall_checker.is_colliding()
				and ice.is_on_wall()):
				ice.velocity.x = 0
				ice.animation_play("idle")
				ice.direction = Constant.Direction.LEFT
				story_stage = -1
				story_stage_changed.emit()
		5:
			icemaker.scale = Vector2(randf_range(0.95, 1.05), randf_range(0.95, 1.05))
		10:
			icemaker_speed += delta * Constant.gravity / 2
			icemaker.global_position.y += icemaker_speed * delta
			ice_npc_speed += delta * Constant.gravity / 2
			ice_npc.global_position.y += ice_npc_speed * delta


func _input(event: InputEvent) -> void:
	if storying and player.alive:
		if event.is_action_pressed("ui_accept"):
			Engine.time_scale = 4
		elif event.is_action_released("ui_accept"):
			Engine.time_scale = 1

func animation_ice_hurt() -> void:
	ice_npc.animation_play("hurt")

func animation_icemaker_start_shock() -> void:
	story_stage = 5

func animation_icemaker_end_shock() -> void:
	story_stage = -1
	icemaker.set_deferred("scale", Vector2.ONE)

func animation_start_fall() -> void:
	story_stage = 10

func animation_end_fall() -> void:
	story_stage = -1

func animation_play_explosion() -> void:
	SoundManager.play_sfx("ExplosionShort")

func animation_play_start_charge() -> void:
	SoundManager.play_sfx("ChargeLoop")

func animation_play_end_charge() -> void:
	SoundManager.stop_sfx("ChargeLoop")

func _on_icemaker_switch_updated(context: String) -> void:
	if context != "start":
		return
	storying = true
	InputManager.disabled = true
	icemaker_switch.dialog.disabled = true
	icemaker_particle.emitting = false
	SoundManager.play_sfx("PowerClose")
	SoundManager.stop_sfx("IcemakerLoop")
	await UIManager.special_effect.movie_in(1)
	await get_tree().create_timer(1).timeout
	# npc准备
	ice_npc.dialog.root_dialog = ice_npc.battle_dialog
	ice_npc.direction = Constant.Direction.LEFT
	ice_npc.animation_play("normal")
	await get_tree().create_timer(1).timeout
	ice_npc.dialog.disabled = false
	player.face_direction = Constant.Direction.RIGHT
	
func _on_ice_defeated() -> void:
	Achievement.set_achievement(Achievement.ID.DEFEAT_ICE)
	SoundManager.play_bgm(bgm)
	storying = true
	InputManager.disabled = true
	# 移除玩家碰撞
	player.hurt_timer.stop()
	player.reset_flash.call_deferred()
	player.hurtbox.disabled = true
	# 故事
	ice.velocity.x = 0
	ice.animation_play("hurt")
	await UIManager.special_effect.movie_in(1)
	UIManager.status_panel.boss_health_bar_container.hide()
	ice.direction = Constant.Direction.RIGHT
	ice.animation_play("walk")
	story_stage = 0
	await story_stage_changed
	await get_tree().create_timer(0.5).timeout
	ice_npc.animation_play("idle")
	ice_npc.direction = Constant.Direction.LEFT
	ice_npc.global_position = ice.global_position
	ice_npc.show()
	ice.queue_free()
	await get_tree().create_timer(0.5).timeout
	animation_player.play("end")
	await animation_player.animation_finished
	ice_npc.queue_free()
	icemaker.queue_free()
	await get_tree().create_timer(1).timeout
	# 恢复玩家状态
	player.status.health = player.status.max_health
	player.status.potion = player.status.max_potion
	await UIManager.special_effect.movie_out(1)
	player.hurtbox.disabled = false
	InputManager.disabled = false
	storying = false
	explore_status = Constant.ExploreStatus.COMPLETE
	breakable_object.queue_free()


func _on_ice_npc_updated(context: String) -> void:
	if context != "ended":
		return
	ice_npc.dialog.disabled = true
	ice_npc.animation_play("ready")
	await ice_npc.animation_player.animation_finished
	# boss准备
	ice.global_position = ice_npc.global_position
	ice.direction = Constant.Direction.LEFT
	ice.show()
	ice_npc.hide()
	ice_npc.global_position = Vector2.ZERO
	await get_tree().create_timer(1).timeout
	# 开始战斗
	SoundManager.play_bgm(preload("res://asset/music/boss_middle.ogg"))
	UIManager.status_panel.update_boss_health(ice.status.health, ice.status.max_health)
	UIManager.status_panel.boss_health_bar_container.show()
	await UIManager.special_effect.movie_out(1)
	ice.start_battle()
	InputManager.disabled = false
	storying = false
	
