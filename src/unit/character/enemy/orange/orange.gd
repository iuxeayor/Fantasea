extends Enemy

const ORANGE_EXPLOSION_BULLET: PackedScene = preload("res://src/unit/character/enemy/orange/orange_explosion_bullet.tscn")

var target_position: Vector2 = Vector2.ZERO # 目标点
var patrol_position: Vector2 = Vector2.ZERO # 巡逻时，会在该点附近移动
var patrol_direction: Vector2 = Vector2.ZERO # 巡逻方向
var dead: bool = false # 是否死亡
var dead_gravity: float = 0 # 死亡掉落时移动速度
var activated: bool = false # 是否被激活

@onready var explosion_point: Marker2D = $Graphics/ExplosionPoint
@onready var player_checker: RayCast2D = $PlayerChecker
@onready var give_up_timer: Timer = $Timers/GiveUpTimer
@onready var activate_timer: Timer = $Timers/ActivateTimer


func _ready() -> void:
	super ()
	target_position = global_position
	patrol_position = global_position
	patrol_direction = global_position.direction_to(patrol_position
		+ Vector2(randf_range(-4, 4), randf_range(-4, 4)))
	_register_object("orange_explosion_bullet", ORANGE_EXPLOSION_BULLET, 1)

func _physics_process(delta: float) -> void:
	super (delta)
	if dead:
		# 手动重力，因为图像本身没有运动逻辑
		dead_gravity += Constant.gravity * delta
		sprite_2d.position.y += dead_gravity * delta
		sprite_2d.position.x += knockback_speed * delta * -direction

func die() -> void:
	alive = false
	dead = true
	hurt_timer.start(1000)
	drop_loot()
	# 关闭碰撞
	hitbox.disabled = true
	hurtbox.disabled = true
	collision_shape_2d.set_deferred("disabled", true)
	behavior_tree.reset()
	behavior_tree.disabled = true
	set_deferred("velocity", Vector2.ZERO)
	# 动画
	animation_player.play("die")
	await animation_player.animation_finished
	var bullet: CharacterBullet = Game.get_object("orange_explosion_bullet")
	if bullet != null:
		bullet.spawn(explosion_point.global_position, Vector2.ZERO)
	hide()
	queue_free()

func _on_hurt_timer_timeout() -> void:
	super ()
	animation_player.play("idle")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "die":
		queue_free()


func _on_patrol_timer_timeout() -> void:
	# 随机设定一个目标点
	patrol_direction = global_position.direction_to(patrol_position
		+ Vector2(randf_range(-4, 4), randf_range(-4, 4)))


func _on_seek_timer_timeout() -> void:
	if not activated:
		return
	var player_position: Vector2 = Game.get_player().global_position
	player_checker.target_position = player_checker.to_local(player_position + Vector2(0, -8))
	if player_checker.is_colliding() and player_checker.get_collider() is Player:
		target_position = player_position
		give_up_timer.start()
	

func _on_give_up_timer_timeout() -> void:
	# 放弃追击
	target_position = global_position


func _on_activate_timer_timeout() -> void:
	if Game.get_player() != null:
		# 玩家进入一定范围时才会激活
		if Game.get_player().global_position.distance_to(global_position) < 160:
			activated = true
			activate_timer.stop()
