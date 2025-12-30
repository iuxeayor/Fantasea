extends CharacterBody2D

signal finished

var disabled: bool = true:
	set(v):
		disabled = v
		if is_node_ready():
			if disabled:
				position = Vector2.ZERO
				velocity = Vector2.ZERO
				hitbox.disabled = true
				hide()
				if Game.get_game_scene() != null:
					Game.get_game_scene().object_pool.recycle_object("watermelon_seed", self)
				finished.emit()
			else:
				hitbox.disabled = false
				show()
				moving = true

# 直接disable可能导致碰撞检测失效，所以使用moving来控制
var moving: bool = false:
	set(v):
		if v != moving:
			moving = v
			if is_node_ready() and not moving:
				hit_particle_queue.trigger.call_deferred(global_position)
				set_deferred("disabled", true)

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var hitbox: Hitbox = $Hitbox
@onready var hit_particle_queue: ParticleQueue = $HitParticleQueue

func _physics_process(delta: float) -> void:
	if moving:
		sprite_2d.rotate(1.5 * TAU * delta)
		move_and_slide()
		if (is_on_floor()
			or is_on_wall()
			or is_on_ceiling()):
			SoundManager.play_sfx("SeedHit")
			moving = false
		
			
func use(location: Vector2, velo: Vector2, damage: int) -> void:
	if not disabled or moving:
		return
	disabled = false
	global_position = location
	velocity = velo
	hitbox.damage = damage

func _on_hitbox_collided(_source: Hitbox.CollideSource, _damage: int, _position: Vector2) -> void:
	moving = false

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	if not disabled:
		moving = false
