extends Action

@export var min_stage: int = 0
@export var max_stage: int = 0

func tick(_delta: float) -> BTState:
	if character.battle_stage >= min_stage and character.battle_stage <= max_stage:
		return BTState.SUCCESS
	return BTState.FAILURE
