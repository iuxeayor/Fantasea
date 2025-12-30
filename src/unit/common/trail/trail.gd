extends Line2D
class_name Trail

@export var length: float = 100
@export var origin_offset: Vector2 = Vector2.ZERO

var real_length: float = length

func _ready() -> void:
	real_length = length * Engine.physics_ticks_per_second / 60
	for i in range(real_length):
		add_point(global_position)

func _physics_process(_delta: float) -> void:
	global_position = Vector2.ZERO
	add_point(get_parent().global_position + origin_offset)
	remove_point(0)

func reset() -> void:
	clear_points()
	for i in range(real_length):
		add_point(get_parent().global_position + origin_offset)
