extends Item

func _update_message() -> void:
	message = tr("ITEM_JELLY") % [
		InputManager.action_to_text("throw"),
		]
