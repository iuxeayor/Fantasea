extends Enemy

var resurrecting: bool = false
var resurrect_times: int = 2

var speed: int = 80

@onready var resurrect_timer: Timer = $Timers/ResurrectTimer

func die() -> void:
	if resurrect_times <= 0:
		super()
		return
	resurrect_times -= 1
	resurrecting = true
	behavior_tree.reset()
	hitbox.disabled = true
	hurtbox.disabled = true
	hurt_timer.stop()
	reset_flash.call_deferred()
	resurrect_timer.start(0.2)


func _on_resurrect_timer_timeout() -> void:
	status.health += 1
	if status.health < status.max_health:
		resurrect_timer.start(0.1)
	else:
		resurrecting = false
		speed = 80 + 20 * (2 - resurrect_times)
		resurrect_timer.stop()
