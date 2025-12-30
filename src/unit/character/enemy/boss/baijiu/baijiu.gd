extends Boss

const EXPLOSION_DAMAGE: int = 50

const ALCOHOL_BULLET: PackedScene = preload("res://src/unit/character/enemy/boss/baijiu/alcohol_bullet.tscn")
const ALCOHOL_EXPLOSION_BULLET: PackedScene = preload("res://src/unit/character/enemy/boss/baijiu/alcohol_explosion_bullet.tscn")

signal stage_change

var current_platform_index: int = 3 # 四个平台，与STAND_POINT_X对应，初始在最右边的平台
var heavy_hurt: bool = false

@onready var attack_point: Marker2D = $AttackPoint

func _ready() -> void:
	super()
	_register_object("alcohol_bullet", ALCOHOL_BULLET, 40)
	_register_object("alcohol_explosion_bullet", ALCOHOL_EXPLOSION_BULLET, 50)

func hurt(damage: int) -> void:
	super(damage)
	if damage >= EXPLOSION_DAMAGE:
		hurt_timer.start(0.6)
	else:
		hurt_timer.start(0.2)
	if damage >= Game.get_player().status.raw_attack:
		heavy_hurt = true
	if status.health <= 0:
		stop_battle()
		defeated.emit()
	

func _on_hurtbox_collided(source: Hitbox.CollideSource, damage: int, _location: Vector2) -> void:
	super(source, damage, _location)
	if (source == Hitbox.CollideSource.BULLET
		and hurt_timer.is_stopped()):
		hurt(EXPLOSION_DAMAGE)

func _pass() -> void: # 用于忽悠lsp
	stage_change.emit()
