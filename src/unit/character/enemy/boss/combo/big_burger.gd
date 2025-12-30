extends Boss

signal combo_attack
signal health_changed

var attack_signal: bool = false
var waiting_signal: bool = false
var is_defeated: bool = false

@onready var land_particle: GPUParticles2D = $LandParticle

func _ready() -> void:
	super()
	UIManager.status_panel.boss_health_bar_container.update_separator([] as Array[int])

func _physics_process(delta: float) -> void:
	if is_defeated:
		if is_on_floor() and is_zero_approx(velocity.y):
			velocity = Vector2.ZERO
			animation_play("stun")
			is_defeated = false
	super(delta)
	

func hurt(damage: int) -> void:
	super(damage)
	hurt_particle.trigger(sprite_2d.global_position)
	if status.health <= 0:
		stop_battle()
		defeated.emit()
		if global_position.x < Game.get_player().global_position.x:
			direction = Constant.Direction.RIGHT
		else:
			direction = Constant.Direction.LEFT
		velocity = Vector2(-direction * 60, -120)
		animation_play("hurt")
		is_defeated = true

func is_dead() -> bool:
	return status.health <= 0

func _on_status_status_changed(_type_name: StringName, _value: Variant) -> void:
	health_changed.emit()

func _pass() -> void:
	combo_attack.emit()
