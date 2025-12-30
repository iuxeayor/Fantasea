@tool
extends Npc


func _on_dialog_content_ended() -> void:
	completed.emit()
