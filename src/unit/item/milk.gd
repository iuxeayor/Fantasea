extends Item

func _collect() -> void:
	Status.player_status.number_collection["potion"] += 1
	var status: PlayerCharacterStatus = Game.get_player().status
	status.max_potion += 1
	status.potion = status.max_potion
	status.potion_store += status.max_potion + status.max_health
	# 程序设计缺陷，库存页面通过整体Status来获取药水数量，所以需要更新Status
	Status.player_status.potion_store = status.potion_store

func _update_message() -> void:
	message = tr("ITEM_MILK") % [
		InputManager.action_to_text("heal"),
		Status.player_status.number_collection.get("potion", 0),
		Game.get_player().status.potion_store
		]
