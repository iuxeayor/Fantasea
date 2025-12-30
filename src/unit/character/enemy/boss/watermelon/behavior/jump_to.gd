extends Action

enum Target {
	PLAYER,
	LOCAL,
}

@export var target: Target = Target.PLAYER ## 跳跃目标
@export var jump_velocity: float = 0: ## 跳跃高度
	set(v):
		jump_velocity = min(v, 0)
@export var max_distance: float = 400: ## 最远跳跃距离
	set(v):
		max_distance = max(0, v)

func enter() -> void:
	super ()
	character.animation_play("jump")
	var target_position: Vector2 = character.global_position
	match target:
		Target.PLAYER:
			var player: Player = Game.get_player()
			target_position = player.global_position
			SoundManager.play_sfx("WatermelonJump")
	# 计算横向跳跃速度
	var velocity_x: float = Util.calculate_x_velocity_parabola(character.global_position,
		target_position,
		jump_velocity,
		Constant.gravity,
		max_distance)
	character.velocity = Vector2(velocity_x, jump_velocity)

func tick(_delta: float) -> BTState:
	if character.velocity.y > 0:
		return BTState.SUCCESS
	return BTState.RUNNING
