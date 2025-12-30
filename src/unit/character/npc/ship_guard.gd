@tool
extends Npc

@export var mech: Node2D = null
@onready var powerless_dialog: DialogContent = $Dialog/Powerless
@onready var normal_dialog: DialogContent = $Dialog/Normal
@onready var pass_dialog: DialogContent = $Dialog/Pass

func _on_pass_ended() -> void:
	mech.open()
