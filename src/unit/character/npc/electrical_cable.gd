@tool
extends Npc

func _ready() -> void:
	super()
	if Engine.is_editor_hint():
		dialog.hide()

func _on_connect_started() -> void:
	completed.emit()
	animation_play("connect")
