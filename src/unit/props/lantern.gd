extends Node2D

@export var close: bool = false # 性能问题，在某些场景关闭

@onready var point_light_2d: PointLight2D = $PointLight2D

func _ready() -> void:
	if not Status.scene_status.story.get("main_sleep", false):
		point_light_2d.energy = 1
	else:
		if close:
			point_light_2d.queue_free()
	
