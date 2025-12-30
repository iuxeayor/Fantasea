extends Action

# 子弹不正常消失的谜之bug，手动重置一下

func enter() -> void:
	Game.get_game_scene().bullet_reset()

func tick(_delta: float) -> BTState:
	return BTState.SUCCESS
