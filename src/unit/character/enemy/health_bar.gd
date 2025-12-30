extends ProgressBar

@onready var display_timer: Timer = $DisplayTimer

	
func _on_display_timer_timeout() -> void:
	hide()


func _on_status_status_changed(type_name: StringName, v: Variant) -> void:
	if not is_node_ready():
		return
	match type_name:
		"max_health":
			max_value = v
		"health":
			value = v
			show()
			display_timer.start()
