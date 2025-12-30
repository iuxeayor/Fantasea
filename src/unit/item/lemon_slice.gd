extends Item

func _collect() -> void:
	super()
	var player: Player = Game.get_player()
	player.shoot_cd_timer.wait_time = Constant.FAST_SHOOT_CD_TIME
	player.status.shoot_attack = Util.get_shoot_power(player.status.shoot_level + 1)
