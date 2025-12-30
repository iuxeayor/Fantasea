extends Node
class_name CharacterStatus

signal status_changed(type_name: StringName, value: Variant)

func emit_status_changed(type_name: StringName, value: Variant) -> void:
	if not is_node_ready():
		return
	status_changed.emit(type_name, value)

@export_range(1, 2048) var max_health: int = 1:
	set(v):
		max_health = max(1, v)
		health = max_health
		emit_status_changed("max_health", max_health)

var health: int = 1:
	set(v):
		health = clampi(v, 0, max_health)
		emit_status_changed("health", health)
