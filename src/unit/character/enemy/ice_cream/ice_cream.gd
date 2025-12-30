extends Enemy

const ICE_CREAM_BULLET: PackedScene = preload("res://src/unit/character/enemy/ice_cream/ice_cream_bullet.tscn")
const MELTED_ICE_CREAM_BULLET: PackedScene = preload("res://src/unit/character/enemy/ice_cream/melted_ice_cream_bullet.tscn")

@onready var melt_timer: Timer = $Timers/MeltTimer
@onready var shoot_point: Marker2D = $Graphics/ShootPoint

func _ready() -> void:
	super ()
	_register_object("ice_cream_bullet", ICE_CREAM_BULLET, 5)
	_register_object("melted_ice_cream_bullet", MELTED_ICE_CREAM_BULLET, 15)
	melt_timer.start(1)

func _on_melt_timer_timeout() -> void:
	var bullet: CharacterBullet = Game.get_object("ice_cream_bullet")
	if bullet == null:
		return
	bullet.spawn(shoot_point.global_position, Vector2.ZERO)
	melt_timer.start(randf_range(0.75, 1.5))
