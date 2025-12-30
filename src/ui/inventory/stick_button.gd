extends ItemButton

func update(level: int) -> void:
	var action_text: String = InputManager.action_to_text("attack")
	match level:
		1:
			info = tr("ITEM_WOOD_STICK") % action_text
			item_icon = preload("res://asset/texture/unit/item/wood_stick.webp")
		2:
			info = tr("ITEM_PLASTIC_STICK") % action_text
			item_icon = preload("res://asset/texture/unit/item/plastic_stick.webp")
		3:
			info = tr("ITEM_CERAMIC_STICK") % action_text
			item_icon = preload("res://asset/texture/unit/item/ceramic_stick.webp")
		4:
			info = tr("ITEM_METAL_STICK") % action_text
			item_icon = preload("res://asset/texture/unit/item/metal_stick.webp")
		5:
			info = tr("ITEM_TITANIUM_STICK") % action_text
			item_icon = preload("res://asset/texture/unit/item/titanium_stick.webp")
		_:
			info = tr("ITEM_WOOD_STICK") % action_text
			item_icon = preload("res://asset/texture/unit/item/wood_stick.webp")
