@tool
extends Npc

@onready var end_dialog: DialogContent = $Dialog/End

func _on_battle_started() -> void:
	updated.emit("battle")
