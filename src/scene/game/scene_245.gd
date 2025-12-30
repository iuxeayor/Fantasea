extends "res://src/scene/game/base/ship_scene.gd"

const LEFT_TOP:Vector2 = Vector2(152, 80)
const RIGHT_BOTTOM:Vector2 = Vector2(232, 120)

var storying: bool = false:
	set(v):
		storying = v
		if storying:
			Engine.time_scale = 1
		else:
			Engine.time_scale = Config.game_speed

@onready var dark_light: DirectionalLight2D = $Lights/DarkLight
@onready var final_bread: Npc = $FinalBread
@onready var whole_wheat_bread: Boss = $WholeWheatBread
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var cd_timer: Timer = $CDTimer
@onready var end_particle: Node2D = $Units/EndParticle
@onready var defeat_particle: GPUParticles2D = $Units/EndParticle/DefeatParticle
@onready var defeat_particle_2: GPUParticles2D = $Units/EndParticle/DefeatParticle2
@onready var defeat_particle_3: GPUParticles2D = $Units/EndParticle/DefeatParticle3
@onready var defeat_particle_4: GPUParticles2D = $Units/EndParticle/DefeatParticle4

var loop_end: bool = false

func _before_ready() -> void:
	storying = true
	InputManager.disabled = true
	UIManager.special_effect.movie_in(0)
	whole_wheat_bread.hide()

func _ready() -> void:
	super()
	await get_tree().create_timer(2).timeout
	SoundManager.play_sfx("PowerClose")
	dark_light.queue_free()
	await get_tree().create_timer(2).timeout
	final_bread.dialog.disabled = false

func _input(event: InputEvent) -> void:
	if storying and player.alive:
		if event.is_action_pressed("ui_accept"):
			Engine.time_scale = 4
		elif event.is_action_released("ui_accept"):
			Engine.time_scale = 1

func _on_final_bread_completed() -> void:
	whole_wheat_bread.global_position = final_bread.global_position
	whole_wheat_bread.show()
	final_bread.hide()
	final_bread.global_position = object_pool.global_position
	await get_tree().create_timer(1).timeout
	UIManager.status_panel.update_boss_health(whole_wheat_bread.status.health, whole_wheat_bread.status.max_health)
	UIManager.status_panel.boss_health_bar_container.show()
	await UIManager.special_effect.movie_out(1)
	whole_wheat_bread.start_battle()
	animation_player.play("1")
	SoundManager.play_sfx("KnifeLoop")
	SoundManager.play_bgm(preload("res://asset/music/boss_final.ogg"))
	InputManager.disabled = false
	storying = false
	


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name.to_int() == 0:
		return
	if anim_name == "22" and not loop_end:
		loop_end = true
	var new_anim_name: StringName = str(anim_name.to_int() + 1)
	if loop_end:
		new_anim_name = str(randi_range(16, 22))
	if animation_player.has_animation(new_anim_name):
		cd_timer.start()
		await cd_timer.timeout
		animation_player.play.call_deferred("RESET")
		animation_player.advance.call_deferred(0)
		animation_player.play.call_deferred(new_anim_name)
		animation_player.advance.call_deferred(0)
		SoundManager.play_sfx("KnifeLoop")


func _on_whole_wheat_bread_defeated() -> void:
	Achievement.set_achievement(Achievement.ID.DEFEAT_WHOLE_WHEAT_BREAD)
	storying = true
	cd_timer.stop()
	animation_player.play("RESET")
	SoundManager.stop_sfx("KnifeLoop")
	SoundManager.stop_bgm()
	InputManager.disabled = true
	player.hurt_timer.stop()
	player.reset_flash()
	player.hurtbox.disabled = true
	final_bread.global_position = whole_wheat_bread.global_position
	final_bread.show()
	final_bread.animation_play("hurt")
	whole_wheat_bread.hide()
	whole_wheat_bread.queue_free()
	game_camera.shake(2, 100)
	defeat_particle.lifetime = randf_range(0.2, 0.4)
	defeat_particle.restart()
	defeat_particle_2.lifetime = randf_range(0.3, 0.5)
	defeat_particle_2.restart()
	defeat_particle_3.lifetime = randf_range(0.4, 0.6)
	defeat_particle_3.restart()
	defeat_particle_4.lifetime = randf_range(0.5, 0.7)
	defeat_particle_4.restart()
	SoundManager.play_sfx("ExplosionShortMute")
	await get_tree().create_timer(1).timeout
	await UIManager.special_effect.movie_in(1)
	UIManager.status_panel.boss_health_bar_container.hide()
	await get_tree().create_timer(2).timeout
	await UIManager.special_effect.fade_in(1)
	await get_tree().create_timer(2).timeout
	for _i: int in range(10):
		SoundManager.play_sfx("ExplosionShort")
		await get_tree().create_timer(0.1).timeout
	end_particle.queue_free()
	await get_tree().create_timer(3).timeout
	Game.get_game_scene().to_status()
	Status.scene_status.scene_index = 238
	Status.scene_status.story["game_clear"] = true
	Status.save_to_file(Game.save_name)
	get_tree().change_scene_to_file("res://src/ui/end.tscn")


func _on_defeat_particle_finished() -> void:
	defeat_particle.global_position = Vector2(
		randf_range(LEFT_TOP.x, RIGHT_BOTTOM.x),
		randf_range(LEFT_TOP.y, RIGHT_BOTTOM.y))
	defeat_particle.lifetime = randf_range(0.2, 0.4)
	defeat_particle.restart.call_deferred()
	SoundManager.play_sfx("ExplosionShortMute")


func _on_defeat_particle_2_finished() -> void:
	defeat_particle_2.global_position = Vector2(
		randf_range(LEFT_TOP.x, RIGHT_BOTTOM.x),
		randf_range(LEFT_TOP.y, RIGHT_BOTTOM.y))
	defeat_particle_2.lifetime = randf_range(0.2, 0.4)
	defeat_particle_2.restart.call_deferred()
	SoundManager.play_sfx("ExplosionShortMute")


func _on_defeat_particle_3_finished() -> void:
	defeat_particle_3.global_position = Vector2(
		randf_range(LEFT_TOP.x, RIGHT_BOTTOM.x),
		randf_range(LEFT_TOP.y, RIGHT_BOTTOM.y))
	defeat_particle_3.lifetime = randf_range(0.2, 0.4)
	defeat_particle_3.restart.call_deferred()
	SoundManager.play_sfx("ExplosionShortMute")


func _on_defeat_particle_4_finished() -> void:
	defeat_particle_4.global_position = Vector2(
		randf_range(LEFT_TOP.x, RIGHT_BOTTOM.x),
		randf_range(LEFT_TOP.y, RIGHT_BOTTOM.y))
	defeat_particle_4.lifetime = randf_range(0.2, 0.4)
	defeat_particle_4.restart.call_deferred()
	SoundManager.play_sfx("ExplosionShortMute")
