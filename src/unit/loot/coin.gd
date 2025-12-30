extends RigidBody2D

@export var value: int = 1
var attracting: bool = false # 是否被吸引

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var attract_collision: CollisionShape2D = $Node/Checker/AttractChecker/AttractCollision
@onready var tile_collision: CollisionShape2D = $Node/Checker/TileChecker/TileCollision
@onready var tile_checker: Area2D = $Node/Checker/TileChecker

func _ready() -> void:
	linear_velocity.x = randi_range(-100, 100)
	linear_velocity.y = -200
	
func _physics_process(delta: float) -> void:
	if not attracting:
		return
	var target_velocity: Vector2 = (Game.get_player().global_position
		+ Vector2(0, -8)
		- global_position).normalized() * Constant.MOVE_SPEED * 2
	linear_velocity = lerp(linear_velocity, target_velocity, delta * 2)
	look_at(linear_velocity + global_position)

func _collect() -> void:
	if Game.get_player() == null:
		return
	Game.get_player().status.money += value
	SoundManager.play_sfx("CoinCollect")
	queue_free()


func _on_player_collect_checker_body_entered(body: Node2D) -> void:
	if body is Player:
		_collect()


func _on_tile_checker_body_entered(body: Node2D) -> void:
	if body is TileMapLayer:
		_collect()

func _on_attract_checker_body_entered(body: Node2D) -> void:
	if not body is Player:
		return
	attracting = true
	collision_shape_2d.set_deferred("disabled", true)
	tile_collision.set_deferred("disabled", true)
	gravity_scale = 0


func _on_spawn_timer_timeout() -> void:
	# 出生时有一个速度，此时被吸引会导致速度变得奇怪，所以延迟一会儿再打开吸引检测
	if not attracting:
		tile_collision.set_deferred("disabled", false)
	if Status.player_status.collection.get("magnet", false):
		attract_collision.set_deferred("disabled", false)
