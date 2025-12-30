@tool
extends Npc

@onready var battle_dialog: DialogContent = $Dialog/Battle
@onready var end_dialog: DialogContent = $Dialog/End


func _on_battle_ended() -> void:
	updated.emit("battle")
