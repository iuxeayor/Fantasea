@tool
extends Npc



func _on_scan_ended() -> void:
	updated.emit("end")
