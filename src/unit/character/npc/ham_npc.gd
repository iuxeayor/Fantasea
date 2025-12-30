@tool
extends Npc

@onready var start_dialog: DialogContent = $Dialog/Start
@onready var throw_dialog: DialogContent = $Dialog/Throw
@onready var throw_battle_dialog: DialogContent = $Dialog/ThrowBattle
@onready var battle_dialog: DialogContent = $Dialog/Battle
@onready var throw_point: Marker2D = $Graphics/ThrowPoint


func _on_throw_ended() -> void:
	dialog.root_dialog = throw_battle_dialog
	updated.emit("throw")


func _on_battle_ended() -> void:
	updated.emit("battle")
