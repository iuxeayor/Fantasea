extends Action

## 检查器
@export var checkers: Array[RayCast2D] = []
## 为否会反转检查器is_colliding的结果
@export var checkers_logic: Array[bool] = []

# 加个延迟防止鬼畜
var cooldown_timer: Timer = null

func _ready() -> void:
	super()
	cooldown_timer = Timer.new()
	cooldown_timer.one_shot = true
	add_child(cooldown_timer)

func tick(_delta: float) -> BTState:
	if not cooldown_timer.is_stopped():
		return BTState.SUCCESS
	var should_turn: bool = false
	for i: int in range(checkers.size()):
		if checkers_logic[i]:
			if checkers[i].is_colliding():
				should_turn = true
				break
		else:
			if not checkers[i].is_colliding():
				should_turn = true
				break
	if (should_turn
		and not character.falling):
		cooldown_timer.start(0.2)
		character.direction = Constant.Direction.LEFT if character.direction == Constant.Direction.RIGHT else Constant.Direction.RIGHT
	return BTState.SUCCESS
