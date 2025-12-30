extends Item

func _collect() -> void:
	super()
	Game.get_player().attack_cd_timer.wait_time = Constant.FAST_ATTACK_CD_TIME
