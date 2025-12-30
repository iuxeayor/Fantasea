extends State

var is_particle_shoot: bool = false

func enter() -> void:
	character.animation_play("attack")
	character.control_manager.control_buffer_timer.get("attack").stop()
	SoundManager.play_sfx("PlayerAttack")
	is_particle_shoot = false
	
func exit() -> void:
	character.hitbox.disabled = true
	is_particle_shoot = false
	character.attack_cd_timer.start()
	
	
func tick(delta: float) -> void:
	if character.animation_player.current_animation != "attack":
		change_to("ActionSubFSM")
		return
	_hit_wall_particle()
	# 移动
	character.refresh_control_direction()
	character.move(delta,
		character.control_direction,
		Constant.MOVE_SPEED,
		Constant.MOVE_SPEED * Constant.ACCELERATION_MULTIPLIER,
		Constant.gravity)

func _hit_wall_particle() -> void:
	if not is_particle_shoot:
		if (character.hit_wall_checker.is_colliding()
			and not Game.get_game_scene().is_out_of_bounds(
				character.hit_wall_checker.get_collision_point())):
			is_particle_shoot = true
			character.hit_wall_particles.trigger(
				character.hit_wall_checker.get_collision_point(), 
				character.hit_wall_particles.used_color)
			SoundManager.play_sfx("WallHit")
			character.hit_recoil()
