extends Item

func _update_message() -> void:
	message = tr("ITEM_CLUB_SODA") % [
			InputManager.action_to_text("dash")
		]
