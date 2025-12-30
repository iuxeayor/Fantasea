@tool
extends Control

@export var vertical: bool = false:
	set(v):
		vertical = v
		if Engine.is_editor_hint() and is_node_ready():
			if vertical:
				horizontal_container.hide()
				vertical_container.show()
			else:
				vertical_container.hide()
				horizontal_container.show()
				
@onready var horizontal_container: NinePatchRect = $HorizontalContainer
@onready var vertical_container: NinePatchRect = $VerticalContainer
@onready var h_start_collision: CollisionShape2D = $HorizontalContainer/Start/StaticBody2D/HStartCollision
@onready var h_end_collision: CollisionShape2D = $HorizontalContainer/End/StaticBody2D/HEndCollision
@onready var v_start_collision: CollisionShape2D = $VerticalContainer/Start/StaticBody2D/VStartCollision
@onready var v_end_collision: CollisionShape2D = $VerticalContainer/End/StaticBody2D/VEndCollision

func _ready() -> void:
	if vertical:
		horizontal_container.hide()
		vertical_container.show()
	else:
		vertical_container.hide()
		horizontal_container.show()
	if not Engine.is_editor_hint():
		z_index = -10
		horizontal_container.z_index = -10
		vertical_container.z_index = -10
		if vertical:
			h_start_collision.disabled = true
			h_end_collision.disabled = true
			v_start_collision.disabled = false
			v_end_collision.disabled = false
		else:
			h_start_collision.disabled = false
			h_end_collision.disabled = false
			v_start_collision.disabled = true
			v_end_collision.disabled = true
