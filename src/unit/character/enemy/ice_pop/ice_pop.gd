extends Enemy

const STICK_BULLET: PackedScene = preload("res://src/unit/character/enemy/ice_pop/stick_bullet.tscn")

@onready var front_player_checker: RayCast2D = $Graphics/FrontPlayerChecker
@onready var back_player_checker: RayCast2D = $Graphics/BackPlayerChecker
@onready var top_player_checker: RayCast2D = $Graphics/TopPlayerChecker
@onready var attack_cooldown_timer: Timer = $Timers/AttackCooldownTimer
@onready var shoot_point: Marker2D = $Graphics/ShootPoint

func _ready() -> void:
	super ()
	_register_object("stick_bullet", STICK_BULLET, 10)
