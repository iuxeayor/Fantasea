extends ColorRect
class_name MapRoom

@onready var explore_icon: TextureRect = $ExploreIcon
@onready var range_area: Control = $RangeArea
@onready var center: Control = $Center
@onready var border: TileMapLayer = $MapBorder


# 显示探索状态
var is_complete: bool = false:
	set(v):
		is_complete = v
		if is_complete:
			explore_icon.hide()
		else:
			explore_icon.show()

var grid_visible: bool = false:
	set(v):
		grid_visible = v
		if grid_visible:
			self_modulate = Color(1, 1, 1, 1)
			border.self_modulate = Color(1, 1, 1, 1)
		else:
			self_modulate = Color(1, 1, 1, 0)
			border.self_modulate = Color(1, 1, 1, 0)

func get_ratio_position(ratio: Vector2) -> Vector2:
	return Vector2(
		range_area.global_position.x + range_area.size.x * ratio.x,
		range_area.global_position.y + range_area.size.y * ratio.y
	)
