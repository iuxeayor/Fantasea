extends Action

var speed: float = 1200

func enter() -> void:
	super ()
	var direction: Vector2 = character.global_position.direction_to(character.dash_target)
	character.velocity = direction * speed
	character.animation_play("fall")
	character.trail.show()

func exit() -> void:
	super ()
	character.velocity.x = 0
	character.gravity = Constant.gravity
	SoundManager.play_sfx("ButterLandShort")
	Game.get_game_scene().game_camera.shake(1, 0.2)
	character.dash_particle.restart()

func tick(_delta: float) -> BTState:
	if character.is_on_floor() and character.velocity.y == 0:
		return BTState.SUCCESS
	return BTState.RUNNING
