@tool
extends Node2D

signal selected

@export var action_name: StringName = ""
@export_range(8, 48, 1) var radius: float = 8:
	set(v):
		radius = clampf(v, 8, 48)
		queue_redraw()
		if Engine.is_editor_hint() or is_node_ready():
			_handle_icon()

@export var image: Texture2D = null

var finger_index: int = -1

@onready var sprite_2d: Sprite2D = $Sprite2D

func _ready() -> void:
	sprite_2d.texture = image
	_handle_icon()
	queue_redraw()

func _draw() -> void:
	draw_arc(
		Vector2.ZERO,
		radius,
		0,
		TAU,
		32,
		Color.WHITE,
		1,
	)

func _input(event: InputEvent) -> void:
	if (not Util.is_touchscreen_platform()
		or not is_visible_in_tree()):
		return
	if not (event is InputEventScreenDrag or event is InputEventScreenTouch):
		return
	if event is InputEventScreenTouch:
		# 处理手指检测
		if event.pressed:
			if finger_index == -1:
				if event.position.distance_to(global_position) < radius:
					finger_index = event.index
					selected.emit()
		else:
			if event.index == finger_index:
				finger_index = -1
		return
	# 判断是否是当前手指
	if event.index != finger_index:
		return
	# 拖动事件
	global_position = event.position
				

func update(pos: Vector2, rad: float) -> void:
	position = pos
	radius = rad
	_handle_icon()
	queue_redraw()

# 根据半径缩放
func _handle_icon() -> void:
	if (is_node_ready()
		and sprite_2d != null
		and sprite_2d.texture != null):
		sprite_2d.scale = Vector2(radius / 40, radius / 40)
