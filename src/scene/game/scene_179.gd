extends "res://src/scene/game/base/ship_scene.gd"

@onready var gum_bottle: Npc = $Units/GumBottle
@onready var point_light_2d: PointLight2D = $Lights/PointLight2D

func _before_ready() -> void:
	super()
	if Status.scene_status.scene_explore[211] == Constant.ExploreStatus.COMPLETE:
		gum_bottle.queue_free()
		point_light_2d.queue_free()
