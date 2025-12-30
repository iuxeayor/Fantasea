extends Action

func enter() -> void:
	super ()
	character.gravity = Constant.gravity

func tick(_delta: float) -> BTState:
	return BTState.SUCCESS
