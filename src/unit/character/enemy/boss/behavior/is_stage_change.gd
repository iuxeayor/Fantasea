extends Action

var stage: int = 0

func tick(_delta: float) -> BTState:
	if character.battle_stage == stage:
		return BTState.FAILURE
	else:
		stage = character.battle_stage
		# 下落
		character.velocity.y = max(0, character.velocity.y)
		return BTState.SUCCESS
