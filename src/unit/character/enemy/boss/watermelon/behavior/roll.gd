extends Action

@export var target_speed: float = 0:
	set(v):
		target_speed = max(0, v)
# 第一帧不检测墙壁碰撞
var is_first_tick: bool = true

func enter() -> void:
	is_first_tick = true
	# 播放滚动音频
	SoundManager.play_sfx("WatermelonRollLoop")
	# 播放滚动动画
	character.animation_play("roll")
	character.roll_particle.emitting = true
	# 根据移速设置动画播放速度
	character.animation_player.speed_scale = target_speed / 240
	
func exit() -> void:
	# 停止滚动音频
	SoundManager.stop_sfx("WatermelonRollLoop")
	character.roll_particle.emitting = false
	character.direction = - character.direction # 转向
	character.animation_player.speed_scale = 1
	character.hit_wall_particle.restart()
	Game.get_game_scene().game_camera.shake(1, 0.1)
	SoundManager.play_sfx("WatermelonHitWall")

func tick(delta: float) -> BTState:
	if character.wall_checker.is_colliding() and not is_first_tick:
		return BTState.SUCCESS
	var target_velocity: float = character.direction * target_speed
	character.velocity.x = move_toward(character.velocity.x, target_velocity, target_speed * 10 * delta)
	is_first_tick = false
	return BTState.RUNNING
