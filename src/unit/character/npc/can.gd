@tool
extends Npc

@onready var normal_dialog: DialogContent = $Dialog/Normal

func _on_money_ended() -> void:
	updated.emit("money")
	if Game.get_player().status.money >= 100:
		normal_dialog.get_target("CAN_MONEY").disabled = true


func _on_work_ended() -> void:
	updated.emit("story")


func _on_meet_started() -> void:
	updated.emit("start")
