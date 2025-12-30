extends DirectionalLight2D

func _ready() -> void:
	if Status.scene_status.story.get("main_sleep", false):
		queue_free()
		return
	show()
