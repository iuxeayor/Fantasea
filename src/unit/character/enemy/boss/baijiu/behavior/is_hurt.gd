extends Action


func enter() -> void:
	character.heavy_hurt = false

func exit() -> void:
	character.heavy_hurt = false

func tick(_delta: float) -> BTState:
	if character.heavy_hurt:
		return BTState.SUCCESS
	return BTState.FAILURE
