extends Button
class_name ItemButton

@export var collected: bool = false:
	set(v):
		collected = v
		if collected:
			icon = item_icon
		else:
			icon = null
@export var info: String = "" ## 介绍

var item_icon: Texture2D = null

func _ready() -> void:
	item_icon = icon


func _on_mouse_entered() -> void:
	grab_focus.call_deferred()
