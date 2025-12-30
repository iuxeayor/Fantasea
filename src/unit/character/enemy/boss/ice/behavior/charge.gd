extends Action

@export var time: float = 2 ## 等待时间
var timer: Timer = null

func _ready() -> void:
	super ()
	timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = time
	add_child(timer)

func enter() -> void:
	super ()
	timer.start()
	SoundManager.play_sfx("ChargeLoop")
	character.charge_particle.emitting = true

func exit() -> void:
	timer.stop()
	SoundManager.stop_sfx("ChargeLoop")
	character.charge_particle.emitting = false
	super ()

func tick(_delta: float) -> BTState:
	if timer.is_stopped():
		return BTState.SUCCESS
	return BTState.RUNNING
