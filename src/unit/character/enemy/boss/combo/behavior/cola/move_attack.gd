extends Action

const MOVE_SPEED: float = 200


var ready_timer: Timer = null

func _ready() -> void:
	super ()
	ready_timer = Timer.new()
	ready_timer.one_shot = true
	ready_timer.wait_time = 0.3
	add_child(ready_timer)


func enter() -> void:
	character.animation_play("attack_walk")
	character.cola_bullet.update(character.wall_checker.get_collision_point())
	character.cola_bullet.start()
	SoundManager.play_sfx("ColaLoop")

func exit() -> void:
	ready_timer.stop()
	character.cola_bullet.end()
	character.animation_play("attacking")
	SoundManager.stop_sfx("ColaLoop")

func tick(delta: float) -> BTState:
	if not ready_timer.is_stopped():
		return BTState.RUNNING
	Game.get_game_scene().game_camera.shake(0.5, 0.1)
	character.cola_bullet.update(character.wall_checker.get_collision_point())
	character.velocity.x = move_toward(
		character.velocity.x,
		character.direction * MOVE_SPEED,
		MOVE_SPEED * 4 * delta)
	if character.move_wall_checker.is_colliding():
		return BTState.SUCCESS
	return BTState.RUNNING
