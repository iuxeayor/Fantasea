extends Enemy

const MUSHROOM_EXPLOSION_BULLET: PackedScene = preload("res://src/unit/character/enemy/black_mushroom/mushroom_explosion_bullet.tscn")

@onready var player_checker_collision: CollisionShape2D = $PlayerChecker/PlayerCheckerCollision
@onready var jelly_checker_collision: CollisionShape2D = $JellyChecker/JellyCheckerCollision

func _ready() -> void:
	super()
	animation_play("hide")
	hitbox.disabled = true
	hurtbox.disabled = true
	_register_object("mushroom_explosion_bullet", MUSHROOM_EXPLOSION_BULLET, 1)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "attack":
		var bullet: CharacterBullet = Game.get_object("mushroom_explosion_bullet")
		if bullet == null:
			return
		bullet.spawn(sprite_2d.global_position, Vector2.ZERO)


func _on_player_checker_body_entered(body: Node2D) -> void:
	if body is Player:
		player_checker_collision.set_deferred("disabled", true)
		jelly_checker_collision.set_deferred("disabled", true)
		animation_play("attack")
		hitbox.disabled = false
		hurtbox.disabled = false

func die() -> void:
	gravity = Constant.gravity
	super()


func _on_jelly_checker_body_entered(body: Node2D) -> void:
	if body == Game.get_game_scene().jelly:
		player_checker_collision.set_deferred("disabled", true)
		jelly_checker_collision.set_deferred("disabled", true)
		animation_play("attack")
		hitbox.disabled = false
		hurtbox.disabled = false
