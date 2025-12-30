@tool
extends Npc

func _ready() -> void:
	super ()
	sprite_2d.frame = 0

func _on_switch_started() -> void:
	sprite_2d.frame = 1
	collision_shape_2d.disabled = true
	updated.emit("start")
