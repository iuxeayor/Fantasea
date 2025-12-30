extends Action

var timer: Timer = null

func _ready() -> void:
	super ()
	timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = 1
	add_child(timer)

func enter() -> void:
	super ()
	timer.start()
	character.velocity.x = 0
	character.gravity = Constant.gravity
	character.animation_play("hurt")
	character.charge_particle.emitting = false
	character.hitbox.disabled = true
	SoundManager.stop_sfx("ChargeLoop")

func exit() -> void:
	super ()
	timer.stop()
	character.hitbox.disabled = false

func tick(_delta: float) -> BTState:
	if timer.is_stopped():
		return BTState.SUCCESS
	return BTState.RUNNING
