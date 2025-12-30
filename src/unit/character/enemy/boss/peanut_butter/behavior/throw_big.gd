extends Action

@export var bullet_number: int = 6
@export var random_offset: float = 10 ## 整体的随机偏移
@export var single_random_offset: float = 0 ## 单个子弹的随机偏移
@export var min_speed: float = 20
@export var max_speed: float = 240
@export var velo_y: float = -460

func exit() -> void:
	super ()
	var dir: float = -1 if character.direction == Constant.Direction.LEFT else 1
	var offset: float = randf_range(-random_offset, random_offset)
	# 速度区间内的等差数列差
	var speed_stage: float = 60
	if bullet_number <= 1:
		speed_stage = 0
	else:
		speed_stage = (max_speed - min_speed) / (bullet_number - 1)
	for i in range(bullet_number):
		var bullet: CharacterBullet = Game.get_object("big_peanut_butter_bullet")
		if bullet == null:
			return
		bullet.spawn(character.throw_point.global_position,
			Vector2((min_speed + speed_stage * i + offset) * dir + randf_range(-single_random_offset, single_random_offset),
			velo_y + randf_range(-single_random_offset, single_random_offset)))
	
func tick(_delta: float) -> BTState:
	return BTState.SUCCESS
