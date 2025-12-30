extends Action

enum Height {
	LOW,
	MID,
	HIGH
}

@export var height: Height = Height.LOW

var low_height: float = 184
var mid_height: float = 160
var high_height: float = 136

func tick(_delta: float) -> BTState:
	# 向上时，超过高度即成功
	if character.velocity.y < 0:
		match height:
			Height.LOW:
				if character.global_position.y <= low_height:
					return BTState.SUCCESS
			Height.MID:
				if character.global_position.y <= mid_height:
					return BTState.SUCCESS
			Height.HIGH:
				if character.global_position.y <= high_height:
					return BTState.SUCCESS
		return BTState.RUNNING
	# 向下时，低于高度即成功
	elif character.velocity.y > 0:
		match height:
			Height.LOW:
				if character.global_position.y >= low_height:
					return BTState.SUCCESS
			Height.MID:
				if character.global_position.y >= mid_height:
					return BTState.SUCCESS
			Height.HIGH:
				if character.global_position.y >= high_height:
					return BTState.SUCCESS
		return BTState.RUNNING
	return BTState.SUCCESS
