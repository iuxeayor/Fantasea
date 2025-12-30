extends Node2D

const RADIUS: float = 8

func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	draw_circle(
		Vector2.ZERO, 
		RADIUS, 
		Color.WHITE)
	# 十字线
	draw_dashed_line(
		Vector2(RADIUS, 0),
		Vector2(-RADIUS, 0),
		Color.BLACK,
		0.5
	)
	draw_dashed_line(
		Vector2(0, RADIUS),
		Vector2(0, -RADIUS),
		Color.BLACK,
		0.5
	)
