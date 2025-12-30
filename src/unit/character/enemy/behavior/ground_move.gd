extends Action

## 移动时的动画名称
@export var animate_name: String = "walk"
## 移动速度
@export var speed: float = 0
## 修正后的移动速度
var real_speed: float = 0

func _ready() -> void:
	if character.random_direction:
		# 移动速度修正，让重合的单位错开
		real_speed = speed + randf_range(-1, 1)
	else:
		# 未随机的角色不适用
		real_speed = speed

func enter() -> void:
	character.animation_play(animate_name)

func tick(delta: float) -> BTState:
	if character.is_on_floor():
		character.velocity.x = move_toward(character.velocity.x,
			character.direction * real_speed,
			(character.knockback_speed + real_speed) * 6 * delta)
	return BTState.SUCCESS
