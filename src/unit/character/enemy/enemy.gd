class_name Enemy
extends Character

@export var enemy_name: StringName = "" ## 敌怪ID
@export var random_direction: bool = true ## 随机出生朝向
@export var direction: Constant.Direction = Constant.Direction.LEFT: ## 出生朝向
	set(v):
		direction = v
		if not is_node_ready():
			await ready
		graphics.scale.x = direction
@export_range(0, 200, 1) var knockback_speed: float = 0 ## 击退速度，应该为正数
@export var hurt_turn: bool = true ## 受伤是否转向伤害来源
@export var hurt_sfx: String = "HitEnemy" ## 受到伤害的音效
@export var gravity: float = 900 ## 受到的重力

var min_drop_coin: int = 0 ## 最小掉落钱币数量
var max_drop_coin: int = 0 ## 最大掉落钱币数量

@onready var hurt_timer: Timer = $Timers/HurtTimer
@onready var hitbox: Hitbox = $Graphics/Hitbox
@onready var hurtbox: Hitbox = $Graphics/Hurtbox
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var visible_on_screen_notifier_2d: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
@onready var behavior_tree: BehaviorTreeNode = $BehaviorTree
@onready var hurt_particle_queue: ParticleQueue = $HurtParticleQueue
@onready var health_bar: ProgressBar = $HealthBar

var falling: bool = false
var alive: bool = true # 用于场景切换判断，在旧的判断中敌怪死亡后直到消失才会被移除，这会导致场景切换时敌怪仍然存在

func _ready() -> void: 
	_load_data()
	health_bar.hide()
	if random_direction:
		if randi() % 2 == 0:
			direction = -direction as Constant.Direction
	animation_player.play("idle")
	

func _process(_delta: float) -> void:
	if hurt_timer.is_stopped():
		return
	hurt_flash()

func _load_data() -> void:
	var data: Dictionary = Constant.ENEMY_DATA.get(enemy_name, null)
	if data == null:
		push_error("Enemy data not found: %s" % enemy_name)
		return
	status.max_health = data.get("max_health", 1)
	status.health = status.max_health
	min_drop_coin = data.get("min_drop_coin", 0)
	max_drop_coin = data.get("max_drop_coin", 0)
	
func _physics_process(delta: float) -> void:
	gravity_move(delta)
	move_and_slide()

func gravity_move(delta: float) -> void:
	if gravity == 0:
		return
	if not is_on_floor():
		velocity.y += gravity * delta
		falling = true
	else:
		falling = false

func hurt(damage: int, damage_direction: Constant.Direction) -> void:
	hurt_timer.start()
	set_process(true)
	behavior_tree.child_nodes[0].reset()
	hurtbox.disabled = true
	animation_player.play("hurt")
	# 伤害
	status.health -= damage
	# 转向
	if hurt_turn:
		direction = damage_direction
	# 击退
	velocity = Vector2(-direction * knockback_speed, -knockback_speed)
	SoundManager.play_sfx(hurt_sfx)
	hurt_particle_queue.trigger(sprite_2d.global_position)

func die() -> void:
	alive = false
	hurt_timer.start(1000)
	drop_loot()
	# 关闭碰撞
	hitbox.disabled = true
	hurtbox.disabled = true
	collision_shape_2d.set_deferred("disabled", true)
	# 在屏幕外，则删除节点
	if not visible_on_screen_notifier_2d.is_on_screen():
		queue_free()

func drop_loot() -> void:
	# 掉落钱币
	var drop_coin_count: int = randi_range(min_drop_coin, max_drop_coin)
	# 有旺财牛奶时额外掉落钱币
	if Status.player_status.collection.get("want_more_milk", false):
		drop_coin_count += min(max_drop_coin, ceili(drop_coin_count * 0.2))
	while drop_coin_count > 0:
		if drop_coin_count >= 100:
			Game.get_game_scene().drop_loot(global_position, Constant.Loot.COIN_100, 1)
			drop_coin_count -= 100
		elif drop_coin_count >= 10:
			Game.get_game_scene().drop_loot(global_position, Constant.Loot.COIN_10, 1)
			drop_coin_count -= 10
		else:
			Game.get_game_scene().drop_loot(global_position, Constant.Loot.COIN_1, 1)
			drop_coin_count -= 1
	# 已经有牛奶时，根据损失的资源掉落牛奶
	var player_status: PlayerCharacterStatus = Game.get_player().status
	if player_status.max_potion > 0:
		# 损失越多掉落概率越大，损失到10时掉落概率最大
		var lost_resource: float = min(10, (
			(player_status.max_health - player_status.health)
			+ (player_status.max_potion - player_status.potion)
		))
		# 概率，[0, 0.2]
		var drop_rate: float = (lost_resource / 10) * 0.2
		if randf() < drop_rate:
			Game.get_game_scene().drop_loot(global_position, Constant.Loot.MILK, 1)

func _register_object(obj_name: StringName, resource: Resource, count: int) -> void:
	Constant.register_object(obj_name, resource)
	Game.register_object_pool(obj_name, count)

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	await get_tree().create_timer(1).timeout
	# 死亡飞出屏幕，移除该节点
	if status.health <= 0:
		queue_free()

func _on_hurt_timer_timeout() -> void:
	set_process(false)
	reset_flash.call_deferred()
	hurtbox.disabled = false
	if status.health > 0:
		hitbox.disabled = false
		hurtbox.disabled = false

func _on_hurtbox_collided(source: Hitbox.CollideSource, damage: int, location: Vector2) -> void:
	match source:
		Hitbox.CollideSource.ENVIRONMENT:
			hurt(status.max_health, -direction)
		Hitbox.CollideSource.PLAYER:
			var damage_direction: Constant.Direction = direction
			if location.x > global_position.x:
				damage_direction = Constant.Direction.RIGHT
			elif location.x < global_position.x:
				damage_direction = Constant.Direction.LEFT
			hurt(damage, damage_direction)

func _on_status_status_changed(type_name: StringName, value: Variant) -> void:
	if status == null or not status.is_node_ready():
		return
	match type_name:
		"health":
			if value <= 0:
				die()
		"attack":
			hitbox.damage = value
