extends Action

var timer: Timer = null

func _ready() -> void:
	super ()
	timer = Timer.new()
	timer.one_shot = true
	add_child(timer)

func enter() -> void:
	SoundManager.play_sfx("ChargeLoop")
	character.velocity.x = 0
	timer.start(character.animation_player.get_animation("charge").length)
	character.animation_play("charge")
	character.charge_particle.emitting = true

func exit() -> void:
	SoundManager.stop_sfx("ChargeLoop")
	timer.stop()
	character.charge_particle.emitting = false

func tick(_delta: float) -> BTState:
	if timer.is_stopped():
		return BTState.SUCCESS
	return BTState.RUNNING
