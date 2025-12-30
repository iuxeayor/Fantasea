extends Enemy

const ICE_POWDER_BULLET: PackedScene = preload("res://src/unit/character/enemy/shaved_ice/ice_powder_bullet.tscn")

@onready var shoot_point: Marker2D = $Graphics/ShootPoint

func _ready() -> void:
	super ()
	_register_object("ice_powder_bullet", ICE_POWDER_BULLET, 30)
