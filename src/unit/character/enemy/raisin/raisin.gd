extends Enemy

const SMALL_RAISIN: PackedScene = preload("res://src/unit/character/enemy/raisin/small_raisin.tscn")

@onready var spawn_timer: Timer = $Timers/SpawnTimer
@onready var spawn_point: Marker2D = $SpawnPoint

func _ready() -> void:
	super()
	spawn_timer.start(randf_range(0.2, 0.5))

func die() -> void:
	gravity = Constant.gravity
	spawn_timer.stop()
	super()


func _on_spawn_timer_timeout() -> void:
	var small_raisin: Enemy = SMALL_RAISIN.instantiate()
	Game.get_game_scene().object_pool.add_child(small_raisin)
	small_raisin.global_position = spawn_point.global_position
	spawn_timer.start(randf_range(1.5, 2.5))
