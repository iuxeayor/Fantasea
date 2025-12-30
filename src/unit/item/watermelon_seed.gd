extends Item

func _update_message() -> void:
	message = tr("ITEM_WATERMELON_SEED") % [
		InputManager.action_to_text("shoot"),
		]
