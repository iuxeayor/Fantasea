extends Button

var button_disabled: bool = false

func _on_mouse_entered() -> void:
	grab_focus.call_deferred()

func _on_focus_entered() -> void:
	SoundManager.play_sfx("DialogFocus")
	UIManager.focusing = self
