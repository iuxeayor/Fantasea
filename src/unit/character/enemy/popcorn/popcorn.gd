extends Enemy

var moving: bool = false

@onready var player_checker: Area2D = $Graphics/PlayerChecker
@onready var shoot_point: Marker2D = $Graphics/ShootPoint
@onready var attack_cool_down_timer: Timer = $Timers/AttackCoolDownTimer
@onready var patrol_timer: Timer = $Timers/PatrolTimer

const POPCORN_BULLET: PackedScene = preload("res://src/unit/character/enemy/popcorn/popcorn_bullet.tscn")

func _ready() -> void:
	super ()
	_register_object("popcorn_bullet", POPCORN_BULLET, 20)

func hurt(damage: int, damage_direction: Constant.Direction) -> void:
	super (damage, damage_direction)
	moving = true
	patrol_timer.start(2)

func _on_patrol_timer_timeout() -> void:
	moving = not moving
	if velocity.x == 0:
		patrol_timer.start(2 + randf_range(-1, 1))
		if randi() % 2 == 0:
			direction = - direction as Constant.Direction
	else:
		patrol_timer.start(2 + randf_range(-1, 1))
