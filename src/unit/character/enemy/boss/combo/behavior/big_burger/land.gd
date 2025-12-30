extends Action

var timer: Timer = null

func _ready() -> void:
	super ()
	timer = Timer.new()
	timer.one_shot = true
	add_child(timer)

func enter() -> void:
	character.velocity.x = 0
	character.land_particle.restart()
	Game.get_game_scene().game_camera.shake(1, 0.4)
	character.animation_play("land")
	timer.start(character.animation_player.get_animation("land").length)
	SoundManager.play_sfx("BurgerLand")

func exit() -> void:
	timer.stop()

func tick(_delta: float) -> BTState:
	if timer.is_stopped():
		return BTState.SUCCESS
	return BTState.RUNNING
