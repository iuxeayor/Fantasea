extends HBoxContainer

var current_value: int = 0
var current_max_value: int = 0

func change(value: int, max_value: int) -> void:
	for i: int in range(get_child_count()):
		var dot: StatusDot = get_child(i)
		if i < max_value:
			dot.show()
		else:
			dot.hide()
		if i < value:
			# 最后一个点才会有动画，前面的点瞬间完成
			# 暂停时不执行动画
			if i != value - 1:
				dot.full(true)
			else:
				dot.full(get_tree().paused)
		else:
			# 最后一个点才会有动画，前面的点瞬间完成
			# 暂停时不执行动画
			if i != value:
				dot.empty(true)
			else:
				dot.empty(get_tree().paused)
