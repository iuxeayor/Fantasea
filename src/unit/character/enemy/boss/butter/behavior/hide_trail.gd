extends Action

func enter() -> void:
	super ()
	character.trail.hide()
	

func tick(_delta: float) -> BTState:
	return BTState.SUCCESS
