@tool
extends Npc


func _on_memory_ended() -> void:
	updated.emit("steal")
