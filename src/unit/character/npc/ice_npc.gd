@tool
extends Npc

@onready var battle_dialog: DialogContent = $Dialog/Battle

func _ready() -> void:
	super()
	animation_player.play("enjoy")


func _on_battle_ended() -> void:
	updated.emit("ended")
