extends Action

const ROTATION_SPEED: float = 90

var direction: int = 1
var start_rotation: float = 0

func enter() -> void:
	character.animation_play("attacking")
	character.cola_bullet.update(character.wall_checker.get_collision_point())
	character.cola_bullet.start()
	start_rotation = character.wall_checker.rotation_degrees
	if randi() % 2 == 0:
		direction = 1
	else:
		direction = -1
	SoundManager.play_sfx("ColaLoop")

func exit() -> void:
	character.cola_bullet.end()
	character.animation_play("attacking")
	SoundManager.stop_sfx("ColaLoop")

func tick(delta: float) -> BTState:
	character.wall_checker.rotation_degrees += ROTATION_SPEED * direction * delta
	character.cola_bullet.update(character.wall_checker.get_collision_point())
	if abs(character.wall_checker.rotation_degrees - start_rotation) >= 360:
		return BTState.SUCCESS
	var x_dir : float = cos(character.wall_checker.rotation_degrees * PI / 180.0)
	if x_dir < 0.0:
		character.direction = Constant.Direction.LEFT
	else:
		character.direction = Constant.Direction.RIGHT
	Game.get_game_scene().game_camera.shake(0.5, 0.1)
	return BTState.RUNNING
