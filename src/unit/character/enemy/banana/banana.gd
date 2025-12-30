extends Enemy


const BANANA_BULLET: PackedScene = preload("res://src/unit/character/enemy/banana/banana_bullet.tscn")

@onready var player_checker: Area2D = $PlayerChecker

func _ready() -> void:
	super ()
	_register_object("banana_bullet", BANANA_BULLET, 10)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "attack":
		animation_player.play("idle")
