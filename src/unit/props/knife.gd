extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	if randi() % 2 == 0:
		animation_player.play("clockwise")
	else:
		animation_player.play("counterclockwise")
	queue_redraw()

func _draw() -> void:
	draw_circle(Vector2.ZERO, 16, Color(1, 1, 1, 0.1))
