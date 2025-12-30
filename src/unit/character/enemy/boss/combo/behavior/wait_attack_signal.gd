extends Action

# 等待其它节点发出攻击信号

func enter() -> void:
	if character.velocity == Vector2.ZERO:
		character.animation_play("idle")
	character.attack_signal = false
	character.waiting_signal = true

func exit() -> void:
	character.attack_signal = false
	character.waiting_signal = false

func tick(_delta: float) -> BTState:
	if character.attack_signal or character.battle_stage == 2:
		return BTState.SUCCESS
	return BTState.RUNNING
