extends Action

const MID_Y: float = 128

enum Target {
	HORIZONTAL,
	VERTICAL,
	INVERT,
}

@export var target: Target = Target.HORIZONTAL

var timer: Timer = null

func _ready() -> void:
	super ()
	timer = Timer.new()
	timer.one_shot = true
	add_child(timer)

func enter() -> void:
	character.hint_animation_player.play("hint")
	match target:
		Target.HORIZONTAL:
			if character.direction == Constant.Direction.LEFT:
				character.wall_checker.rotation_degrees = 180
			else:
				character.wall_checker.rotation_degrees = 0
			timer.start(2.5)
		Target.VERTICAL:
			# 在上层时，只能向下
			if character.global_position.y < MID_Y:
				character.wall_checker.rotation_degrees = 90
			else:
				# 在下层时，只能向上
				character.wall_checker.rotation_degrees = -90
			timer.start(1)
		Target.INVERT:
			# 瞄准玩家反方向
			character.wall_checker.rotation_degrees = (
				character.global_position - Game.get_player().global_position
			).angle() + randf_range(90, 270)
			if character.global_position.x < Game.get_player().global_position.x:
				character.direction = Constant.Direction.LEFT
			else:
				character.direction = Constant.Direction.RIGHT
			timer.start(0.5)
	character.wall_checker.force_raycast_update()
	character.hint_line.points[1] = character.hint_line.to_local(
		character.wall_checker.get_collision_point()
	)
	character.hint_line.show()

func exit() -> void:
	timer.stop()
	character.hint_line.hide()
	character.hint_animation_player.stop()

func tick(_delta: float) -> BTState:
	if timer.is_stopped():
		return BTState.SUCCESS
	return BTState.RUNNING
