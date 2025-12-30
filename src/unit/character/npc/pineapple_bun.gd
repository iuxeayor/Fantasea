@tool
extends Npc

@onready var normal_dialog: DialogContent = $Dialog/Normal

func _on_end_ended() -> void:
	updated.emit("story")


func _on_accept_started() -> void:
	updated.emit("memory")
