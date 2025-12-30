extends Action

const MID_Y: float = 128
const MID_X: float = 192
const JUMP_VELOCITY: float = -460
const WALK_SPEED: float = 180

enum SubState {
	NONE,
	WALK,
	JUMP,
	FALL,
}

var state: SubState = SubState.NONE

var fall_timer: Timer = null

func _ready() -> void:
	super ()
	fall_timer = Timer.new()
	fall_timer.one_shot = true
	fall_timer.wait_time = 0.1
	add_child(fall_timer)

func enter() -> void:
	state = SubState.NONE
	if character.battle_stage >= 2: # 阶段3不行动
		return
	# 朝向中间
	if character.global_position.x < MID_X:
		character.direction = Constant.Direction.RIGHT
	else:
		character.direction = Constant.Direction.LEFT
	var vertical_move: bool = randi() % 2 == 0
	if vertical_move:
		# 在下层，跳到上层
		if character.global_position.y > MID_Y:
			state = SubState.JUMP
			character.velocity.y = JUMP_VELOCITY
			character.animation_play("jump")
		# 在上层，落下到下层
		else:
			state = SubState.FALL
			character.velocity.y = 0
			character.set_collision_mask_value(2, false) # 关闭与平台的碰撞
			character.animation_play("fall")
			fall_timer.start()
	else:
		state = SubState.WALK
		character.move_wall_checker.force_raycast_update()
		character.animation_play("walk")
	
func exit() -> void:
	state = SubState.NONE
	# 朝向中间
	if character.global_position.x < MID_X:
		character.direction = Constant.Direction.RIGHT
	else:
		character.direction = Constant.Direction.LEFT
	character.velocity = Vector2.ZERO
	character.set_collision_mask_value(2, true)
	character.animation_play("idle")

func tick(delta: float) -> BTState:
	match state:
		SubState.WALK:
			character.velocity.x = move_toward(
				character.velocity.x,
				character.direction * WALK_SPEED,
				WALK_SPEED * 2 * delta)
			if character.move_wall_checker.is_colliding():
				return BTState.SUCCESS
		SubState.JUMP:
			if character.velocity.y >= 0:
				state = SubState.FALL
				character.set_collision_mask_value(2, true)
				character.animation_play("fall")
		SubState.FALL:
			if (fall_timer.is_stopped()
				and character.is_on_floor()):
				return BTState.SUCCESS
	return BTState.RUNNING
