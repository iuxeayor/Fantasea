extends Enemy

const GAS_BULLET: PackedScene = preload("res://src/unit/character/enemy/paocai/gas_bullet.tscn")

var bullet_count: int = 0

@onready var attack_timer: Timer = $Timers/AttackTimer
@onready var attack_cd_timer: Timer = $Timers/AttackCDTimer

func _ready() -> void:
	super()
	_register_object("gas_bullet", GAS_BULLET, 60)
	animation_play("sleep")

func hurt(damage: int, damage_direction: Constant.Direction) -> void:
	super(damage, damage_direction)
	if alive and attack_cd_timer.is_stopped():
		animation_play("hurt")
		if damage >= 5: # 够高的伤害才能触发攻击
			bullet_count = randi_range(10, 20)
			attack_timer.start(0.1)
			attack_cd_timer.start()

func die() -> void:
	super()
	attack_timer.stop()
	bullet_count = 0


func _on_attack_timer_timeout() -> void:
	var bullet: CharacterBullet = Game.get_object("gas_bullet")
	if bullet != null:
		bullet.spawn(global_position + Vector2(
			randf_range(-24, 24), randf_range(0, -16)
		), Vector2.ZERO)
	else:
		bullet_count = 0
	bullet_count -= 1
	if bullet_count > 0:
		attack_timer.start(randf_range(0.05, 0.1))

func _on_hurt_timer_timeout() -> void:
	super()
	if alive:
		animation_play("idle")
