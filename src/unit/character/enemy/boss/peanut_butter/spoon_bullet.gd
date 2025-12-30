extends CharacterBullet

enum SpoonState {
	IDLE,
	SHOOTING,
	RETURNING,
}

var spoon_state: SpoonState = SpoonState.IDLE:
	set(v):
		spoon_state = v
		if v == SpoonState.IDLE:
			hitbox.disabled = true
			SoundManager.stop_sfx("PeanutButterSpoonFlyLoop")
			hide()
		else:
			hitbox.disabled = false
			show()

var start_position: Vector2 = Vector2.ZERO
var target_position: Vector2 = Vector2.ZERO
var shoot_speed: float = 360
var shoot_direction: Vector2 = Vector2.ZERO
var distance_to_target: float = 0

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	animation_player.play("rotate")

func _physics_process(delta: float) -> void:
	match spoon_state:
		SpoonState.SHOOTING:
			var progress: float = min(global_position.distance_to(target_position) / distance_to_target + 0.2, 1)
			var desire_velocity: Vector2 = shoot_direction * shoot_speed * progress
			velocity = velocity.lerp(desire_velocity, 5 * delta)
			if (is_on_floor()
				or is_on_wall()
				or is_on_ceiling()
				or global_position.distance_to(target_position) < 4):
				spoon_state = SpoonState.RETURNING
			move_and_slide()
		SpoonState.RETURNING:
			var desire_target: Vector2 = Game.get_game_scene().peanut_butter.spoon_point.global_position
			var desire_velocity: Vector2 = (desire_target - global_position).normalized() * shoot_speed
			velocity = velocity.lerp(desire_velocity, 5 * delta)
			if global_position.distance_to(desire_target) < 4:
				velocity = Vector2.ZERO
				spoon_state = SpoonState.IDLE
			move_and_slide()
			

func is_idle() -> bool:
	return spoon_state == SpoonState.IDLE

func shoot(start: Vector2, target: Vector2) -> void:
	start_position = start
	target_position = target
	global_position = start_position
	distance_to_target = start_position.distance_to(target_position)
	shoot_direction = (target_position - start_position).normalized()
	velocity = shoot_direction * shoot_speed
	spoon_state = SpoonState.SHOOTING
	SoundManager.play_sfx("PeanutButterSpoonFlyLoop")
