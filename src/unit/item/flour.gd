extends Item


func _collect() -> void:
	# 更新玩家最大生命，补满生命
	Status.player_status.number_collection["health_chip"] += 1
	var player_status: PlayerCharacterStatus = Game.get_player().status
	player_status.max_health = Util.get_max_health(Status.player_status.number_collection.get("health_chip", 0))
	player_status.health = player_status.max_health

func _update_message() -> void:
	var count: int = Status.player_status.number_collection.get("health_chip", 0)
	message = tr("ITEM_FLOUR") % [
		Constant.HEALTH_CHIP_DIVISION,
		count,
		Util.get_max_health(count) - Constant.BASE_HP
		]
