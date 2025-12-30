extends ProgressBar

signal finished

var tween: Tween = null

func _heal_after() -> void:
	finished.emit()
	hide()

func play(time: float) -> void:
	show()
	if tween != null and tween.is_running():
		tween.kill()
	tween = create_tween()
	value = 100
	tween.tween_property(self, "value", 0, time)
	tween.finished.connect(_heal_after, CONNECT_ONE_SHOT)

func stop() -> void:
	if tween != null and tween.is_running():
		tween.kill()
	value = 100
	hide()