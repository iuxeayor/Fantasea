class_name Hitbox
extends Area2D

signal collided(source: CollideSource, damage: int, location: Vector2)

enum CollideSource {
	ENVIRONMENT = 0,
	PLAYER = 1,
	ENEMY = 2,
	BULLET = 3,
}

@export var disabled: bool = false:
	set(v):
		disabled = v
		if not is_node_ready():
			return
		if v:
			close_collision()
		else:
			open_collision()
@export var damage: int = 0

func _ready() -> void:
	if disabled:
		close_collision()
	else:
		open_collision()

func open_collision() -> void:
	for child: Node2D in get_children():
		if child is CollisionShape2D or child is CollisionPolygon2D:
			child.set_deferred("disabled", false)

func close_collision() -> void:
	for child: Node2D in get_children():
		if child is CollisionShape2D or child is CollisionPolygon2D:
			child.set_deferred("disabled", true)

func _on_area_entered(area: Area2D) -> void:
	if not area is Hitbox or area.owner == null:
		return
	if area.owner is Player or area.owner.is_in_group("powder_explosion"):
		collided.emit(CollideSource.PLAYER,
			area.damage,
			area.owner.global_position)
	elif area.owner.is_in_group("watermelon_seed"):
		collided.emit(CollideSource.PLAYER,
		area.damage,
		(area.owner.global_position + Game.get_player().global_position) / 2)
	elif (area.owner.is_in_group("enemy")
		or area.owner.is_in_group("boss")):
		collided.emit(CollideSource.ENEMY, area.damage, area.owner.global_position)
	elif area.owner.is_in_group("bullet"):
		collided.emit(CollideSource.BULLET, area.damage, area.owner.global_position)
func _on_body_entered(body: Node2D) -> void:
	if body is TileMapLayer:
		collided.emit(CollideSource.ENVIRONMENT, 0, Vector2.ZERO)
	elif body is Player:
		collided.emit(CollideSource.PLAYER, 0, Vector2.ZERO)
