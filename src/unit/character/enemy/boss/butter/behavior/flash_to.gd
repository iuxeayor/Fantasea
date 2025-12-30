extends Action

enum Target {
	PLAYER,
	LEFT,
	MID_LEFT,
	MID,
	MID_RIGHT,
	RIGHT,
	RANDOM,
	RANDOM_EDGE,
}

var player_close_offset: float = 24

var timer: Timer = null

@export var target: Target = Target.PLAYER
@export var play_animation: bool = false

func _ready() -> void:
	super ()
	timer = Timer.new()
	timer.wait_time = 0.1
	timer.one_shot = true
	add_child(timer)

func enter() -> void:
	super ()
	character.trail.show()
	var scene: Scene = Game.get_game_scene()
	var player: Player = Game.get_player()
	var target_x: float = character.global_position.x
	match target:
		Target.PLAYER:
			target_x = player.global_position.x
		Target.LEFT:
			target_x = scene.left_x
		Target.MID_LEFT:
			target_x = scene.mid_left_x
		Target.MID:
			target_x = scene.mid_x
		Target.MID_RIGHT:
			target_x = scene.mid_right_x
		Target.RIGHT:
			target_x = scene.right_x
		Target.RANDOM:
			target_x = randf_range(scene.left_x, scene.right_x)
		Target.RANDOM_EDGE:
			if randi() % 2 == 0:
				target_x = scene.left_x
			else:
				target_x = scene.right_x
	target_x = clampf(target_x,
		scene.left_x,
		scene.right_x)
	character.animation_play("idle")
	character.global_position.x = target_x
	character.global_position.y = scene.sky_y
	character.velocity = Vector2.ZERO
	character.gravity = 0
	timer.start()

func exit() -> void:
	character.trail.hide()
	timer.stop()
	character.velocity = Vector2.ZERO
	super ()


func tick(_delta: float) -> BTState:
	if timer.is_stopped():
		return BTState.SUCCESS
	return BTState.RUNNING
