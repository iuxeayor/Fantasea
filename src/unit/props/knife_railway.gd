@tool
extends Control

var start_to_end: bool = true

@export var run_time: float = 1.0
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
@onready var knife: Node2D = $Knife
@onready var h_start: Control = $HorizontalContainer/HStart
@onready var h_end: Control = $HorizontalContainer/HEnd
@onready var v_start: Control = $VerticalContainer/VStart
@onready var v_end: Control = $VerticalContainer/VEnd

func _ready() -> void:
	if vertical:
		horizontal_container.hide()
		vertical_container.show()
	else:
		vertical_container.hide()
		horizontal_container.show()
	if not Engine.is_editor_hint():
		if vertical:
			if knife.global_position.distance_to(v_start.global_position) < knife.global_position.distance_to(v_end.global_position):
				start_to_end = true
			else:
				start_to_end = false
		else:
			if knife.global_position.distance_to(h_start.global_position) < knife.global_position.distance_to(h_end.global_position):
				start_to_end = true
			else:
				start_to_end = false
		run(start_to_end)
		


func run(go: bool) -> void:
	var tween: Tween = create_tween()
	if go:
		if vertical:
			tween.tween_property(knife, "global_position", v_end.global_position, run_time)
		else:
			tween.tween_property(knife, "global_position", h_end.global_position, run_time)
	else:
		if vertical:
			tween.tween_property(knife, "global_position", v_start.global_position, run_time)
		else:
			tween.tween_property(knife, "global_position", h_start.global_position, run_time)
	tween.finished.connect(run.bind(not go), CONNECT_ONE_SHOT)
