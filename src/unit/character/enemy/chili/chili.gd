extends Enemy

const CHILI_EXPLOSION_BULLET: PackedScene = preload("res://src/unit/character/enemy/chili/chili_explosion_bullet.tscn")

var dead: bool = false

@onready var explosion_point: Marker2D = $Graphics/ExplosionPoint

func _ready() -> void:
	super ()
	_register_object("chili_explosion_bullet", CHILI_EXPLOSION_BULLET, 1)

func _physics_process(delta: float) -> void:
	super (delta)
	charge_flash(animation_player.current_animation == "charge")
	if dead and is_on_floor():
		velocity.x = 0

func die() -> void:
	alive = false
	set_deferred("dead", true)
	hurt_timer.start(1000)
	drop_loot()
	# 关闭碰撞箱
	hitbox.disabled = true
	hurtbox.disabled = true
	animation_play("charge")
	await animation_player.animation_finished
	var bullet: CharacterBullet = Game.get_object("chili_explosion_bullet")
	if bullet != null:
		bullet.spawn(explosion_point.global_position, Vector2.ZERO)
	hide()
	queue_free()


# 引爆闪烁
func charge_flash(charging: bool) -> void:
	if charging:
		sprite_2d.material.set_shader_parameter("flash_amount", sin(float(Time.get_ticks_msec()) / 40) * 0.25 + 0.25)
