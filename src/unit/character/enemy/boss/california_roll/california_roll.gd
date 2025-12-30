extends Boss

const SHOCK_BULLET: PackedScene = preload("res://src/unit/character/enemy/boss/california_roll/shock_bullet.tscn")
const BULLET_HIT: PackedScene = preload("res://src/unit/character/enemy/boss/california_roll/bullet_hit.tscn")
const ROLL_AFTERIMAGE: PackedScene = preload("res://src/unit/character/enemy/boss/california_roll/roll_afterimage.tscn")
		
@onready var dash_afterimage_timer: Timer = $Timers/DashAfterimageTimer
@onready var down_afterimage_timer: Timer = $Timers/DownAfterimageTimer
@onready var down_hitbox: Hitbox = $Graphics/DownHitbox
@onready var attack_hitbox: Hitbox = $Graphics/AttackHitbox
@onready var shoot_point: Marker2D = $Graphics/ShootPoint
@onready var teleport_particle: ParticleQueue = $TeleportParticle
@onready var gun_smoke_particle: ParticleQueue = $GunSmokeParticle
@onready var player_checker: RayCast2D = $Graphics/PlayerChecker

func _ready() -> void:
	super()
	_register_object("shock_bullet", SHOCK_BULLET, 2)
	_register_object("bullet_hit", BULLET_HIT, 7)
	_register_object("roll_afterimage", ROLL_AFTERIMAGE, 5)

func hurt(damage: int) -> void:
	super(damage)
	hurt_particle.trigger(sprite_2d.global_position)
	if status.health <= 0:
		stop_battle()
		defeated.emit()

func _on_dash_afterimage_timer_timeout() -> void:
	var afterimage: Node2D = Game.get_object("roll_afterimage")
	if afterimage == null:
		return
	afterimage.spawn(global_position, direction, false)


func _on_down_afterimage_timer_timeout() -> void:
	var afterimage: Node2D = Game.get_object("roll_afterimage")
	if afterimage == null:
		return
	afterimage.spawn(global_position, direction, true)
