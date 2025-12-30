extends PointLight2D

func _ready() -> void:
	if not Status.has_collection("gold_steak"):
		hide()
