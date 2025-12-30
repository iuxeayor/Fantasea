class_name State
extends FiniteStateMachine

signal change(target: String)

# 转换状态
func change_to(target: String) -> void:
	change.emit(target)

# 进入状态时调用
func enter() -> void:
	pass

# 退出状态时调用
func exit() -> void:
	pass

# 每帧调用
func tick(_delta: float) -> void:
	pass
