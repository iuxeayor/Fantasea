@tool
extends TouchScreenButton

const NORMAL_COLOR: Color = Color(1, 1, 1, 0.5)

@export var action_name: StringName = ""

@export_range(8, 48, 1) var radius: float = 8:
	set(v):
		radius = clampf(v, 8, 48)
		if Engine.is_editor_hint():
			queue_redraw()
			_handle_icon()

@export var image: Texture2D = null
		
@onready var sprite_2d: Sprite2D = $Sprite2D

func _ready() -> void:
	modulate = NORMAL_COLOR
	shape = CircleShape2D.new()
	shape.radius = radius
	action = action_name
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

func update(pos: Vector2, rad: float) -> void:
	position = pos
	radius = rad
	shape.radius = radius
	_handle_icon()
	queue_redraw()

# 图标标准尺寸64x64，根据半径缩放
func _handle_icon() -> void:
	if (is_node_ready() 
		and sprite_2d != null 
		and sprite_2d.texture != null):
		sprite_2d.scale = Vector2(radius / 40, radius / 40)


func _on_pressed() -> void:
	# 教学时会高亮按钮，按下时取消高亮
	modulate = NORMAL_COLOR
