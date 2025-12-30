extends Action

func enter() -> void:
	character.combo_attack.emit()

func tick(_delta: float) -> BTState:
	return BTState.SUCCESS
