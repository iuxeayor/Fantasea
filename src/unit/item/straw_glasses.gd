extends Item

func _collect() -> void:
	super()
	var player: Player = Game.get_player()
	if Status.has_collection("fresh_milk"):
		player.auto_heal_timer.wait_time = Constant.FAST_AUTO_HEAL_TIME
	else:
		player.auto_heal_timer.wait_time = Constant.AUTO_HEAL_TIME
	player.auto_heal_timer.start()
