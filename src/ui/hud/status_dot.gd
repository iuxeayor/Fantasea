extends TextureProgressBar
class_name StatusDot

var time: float = 0.2
var tween: Tween = null

func full(instant: bool = false) -> void:
	if tween != null and tween.is_running():
		tween.kill()
	if instant:
		value = 100
		return
	tween = create_tween()
	tween.tween_property(self, "value", 100, time * (100 - value) / 100)

func empty(instant: bool = false) -> void:
	if tween != null and tween.is_running():
		tween.kill()
	if instant:
		value = 0
		return
	tween = create_tween()
	tween.tween_property(self, "value", 0, time * value / 100)
