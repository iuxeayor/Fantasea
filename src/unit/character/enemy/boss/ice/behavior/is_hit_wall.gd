extends Action

var is_first_tick: bool = true

func enter() -> void:
	super ()
	is_first_tick = true

func exit() -> void:
	is_first_tick = true
	super ()

func tick(_delta: float) -> BTState:
	if is_first_tick:
		is_first_tick = false
		return BTState.RUNNING
	if character.wall_checker.is_colliding():
		return BTState.SUCCESS
	return BTState.FAILURE
