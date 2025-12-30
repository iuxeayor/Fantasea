extends Action

var timer: Timer = null

func _ready() -> void:
	super ()
	timer = Timer.new()
	timer.one_shot = true
	add_child(timer)

func enter() -> void:
	super ()
	SoundManager.play_sfx("BigMushroomLand")
	timer.start(character.animation_player.get_animation("land").length)
	character.animation_play("land")
	character.land_particle.restart()
	character.land_particle_2.restart()
	Game.get_game_scene().game_camera.shake(4, 0.8)
	Game.get_player().imbalance(2)


func exit() -> void:
	super ()
	timer.stop()

func tick(_delta: float) -> BTState:
	if timer.is_stopped():
		return BTState.SUCCESS
	return BTState.RUNNING
