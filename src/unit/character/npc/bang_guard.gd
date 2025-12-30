@tool
extends Npc

@export var mech: Node2D = null
@onready var info_dialog: DialogContent = $Dialog/Info

func _ready() -> void:
	super()
	if Engine.is_editor_hint():
		dialog.hide()

func _on_card_ended() -> void:
	if mech != null:
		mech.open()


func _on_dialog_changed() -> void:
	info_dialog.get_target("BANG_PARK_CARD").disabled = not Status.player_status.collection.get("bang_card", false)
