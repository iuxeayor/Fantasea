extends Action

var timer: Timer = null

func _ready() -> void:
	super ()
	timer = Timer.new()
	timer.one_shot = true
	add_child(timer)

func enter() -> void:
	timer.start(character.animation_player.get_animation("attack").length)
	character.animation_play("attack")
	character.hurtbox.disabled = true
	character.counter_solid_collision.set_deferred("disabled", false)

func exit() -> void:
	character.counterattack_collision.set_deferred("disabled", true)
	character.counter_solid_collision.set_deferred("disabled", true)
	timer.stop()
	character.hurtbox.disabled = false

func tick(_delta: float) -> BTState:
	if timer.is_stopped():
		return BTState.SUCCESS
	return BTState.RUNNING
