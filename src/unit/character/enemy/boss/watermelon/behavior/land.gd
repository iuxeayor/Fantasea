extends Action

@export var wait_offset: float = 0 ## 等待动画结束的偏移时间

var timer: Timer = null

func _ready() -> void:
	super ()
	timer = Timer.new()
	timer.one_shot = true
	add_child(timer)

func enter() -> void:
	super ()
	character.velocity = Vector2.ZERO
	SoundManager.play_sfx("WatermelonLand")
	timer.start(character.animation_player.get_animation("land").length + wait_offset)
	character.animation_play("land")
	character.land_particle.restart()
	Game.get_game_scene().game_camera.shake(1, 0.4)

func exit() -> void:
	character.animation_play("idle")
	timer.stop()
	super ()

func tick(_delta: float) -> BTState:
	if timer.is_stopped():
		return BTState.SUCCESS
	return BTState.RUNNING
