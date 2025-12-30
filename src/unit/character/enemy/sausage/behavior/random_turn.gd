extends Action

func enter() -> void:
	super()
	# 随机转向一个方向
	character.direction = Constant.Direction.LEFT if randi_range(0, 1) == 0 else Constant.Direction.RIGHT
	character.velocity.x = 0
