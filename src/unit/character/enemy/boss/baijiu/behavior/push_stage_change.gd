extends Action

func exit() -> void:
	character.stage_change.emit()

func tick(_delta: float) -> BTState:
	return BTState.SUCCESS
