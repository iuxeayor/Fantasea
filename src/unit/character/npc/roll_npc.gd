@tool
extends Npc

@onready var start_dialog: DialogContent = $Dialog/Start
@onready var battle_dialog: DialogContent = $Dialog/Battle
@onready var reject_dialog: DialogContent = $Dialog/Reject
@onready var end_dialog: DialogContent = $Dialog/End


func _on_battle_ended() -> void:
	updated.emit("battle")
