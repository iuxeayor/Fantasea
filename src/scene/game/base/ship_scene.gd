extends Scene

func _before_ready() -> void:
	if get_tree().get_nodes_in_group("knife").size() > 0:
		SoundManager.play_sfx("KnifeLoop")
	else:
		SoundManager.stop_sfx("KnifeLoop")


func _exit_tree() -> void:
	SoundManager.stop_sfx("KnifeLoop")
