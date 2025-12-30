extends Action


var timer: Timer = null

func _ready() -> void:
	super ()
	timer = Timer.new()
	timer.one_shot = true
	add_child(timer)


func enter() -> void:
	character.cola_bullet.update(character.wall_checker.get_collision_point())
	character.cola_bullet.start()
	if character.battle_stage == 0:
		timer.start(2.5)
	else:
		timer.start(1)
	SoundManager.play_sfx("ColaLoop")

func exit() -> void:
	timer.stop()
	character.cola_bullet.end()
	SoundManager.stop_sfx("ColaLoop")

func tick(_delta: float) -> BTState:
	if timer.is_stopped():
		return BTState.SUCCESS
	Game.get_game_scene().game_camera.shake(0.5, 0.1)
	return BTState.RUNNING
