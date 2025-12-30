extends "res://src/scene/game/base/ship_scene.gd"

func _before_ready() -> void:
	super()
	Achievement.set_achievement(Achievement.ID.STORY_SHIP)
