extends CharacterBody2D

signal finished

enum FSMState {
	DISABLE,
	MOVING,
	ABLE,
	PRESSING,
	RELEASING
}

var state: FSMState = FSMState.DISABLE:
	set(v):
		state = v
		if is_node_ready():
			match state:
				FSMState.DISABLE:
					hide()
					animation_player.play("RESET")
					platform_collision.set_deferred("disabled", true)
					velocity = Vector2.ZERO
					position = Vector2.ZERO
				FSMState.MOVING:
					show()
					animation_player.play("RESET")
					platform_collision.set_deferred("disabled", true)
				FSMState.ABLE:
					show()
					animation_player.play("RESET")
					platform_collision.set_deferred("disabled", false)
					velocity.x = 0
					able_height = global_position.y
					finish_timer.start()
				FSMState.PRESSING:
					show()
					animation_player.play("press")
					platform_collision.set_deferred("disabled", false)
				FSMState.RELEASING:
					show()
					animation_player.play("release")
					platform_collision.set_deferred("disabled", true)

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var platform: AnimatableBody2D = $Platform
@onready var platform_collision: CollisionShape2D = $Platform/PlatformCollision
@onready var left_player_checker: RayCast2D = $Platform/LeftPlayerChecker
@onready var mid_player_checker: RayCast2D = $Platform/MidPlayerChecker
@onready var right_player_checker: RayCast2D = $Platform/RightPlayerChecker
@onready var land_particle_queue: ParticleQueue = $LandParticleQueue
@onready var spike_particle_queue: ParticleQueue = $SpikeParticleQueue
@onready var finish_timer: Timer = $FinishTimer

var able_height: float = 0

func _physics_process(delta: float) -> void:
	move_and_slide()
	match state:
		FSMState.MOVING:
			velocity.y = min(velocity.y + Constant.gravity * delta, Constant.MAX_FALL_VELOCITY)
			if is_on_floor():
				land_particle_queue.trigger(global_position)
				SoundManager.play_sfx("JellyLand")
				state = FSMState.ABLE
		FSMState.ABLE:
			if not is_on_floor():
				state = FSMState.MOVING
			if is_player_on_platform():
				state = FSMState.PRESSING
			if global_position.y != able_height:
				spike_particle_queue.trigger(global_position + Vector2(0, -5))
				state = FSMState.DISABLE
		_:
			if (state != FSMState.DISABLE
				and not is_on_floor()):
				state = FSMState.MOVING

func use(location: Vector2, velo: Vector2) -> void:
	if state == FSMState.MOVING:
		return
	state = FSMState.MOVING
	global_position = location
	velocity = velo

func is_pushing_player() -> bool:
	return (state == FSMState.RELEASING
		and is_player_on_platform())

func is_player_on_platform() -> bool:
	var player: Player = Game.get_player()
	return ((left_player_checker.is_colliding()
			or mid_player_checker.is_colliding()
			or right_player_checker.is_colliding())
			and player.global_position.y < platform.global_position.y
			and player.velocity.y >= 0)

func _on_spike_checker_body_entered(body: Node2D) -> void:
	if body is TileMapLayer:
		spike_particle_queue.trigger(global_position + Vector2(0, -5))
		state = FSMState.DISABLE
		finish_timer.start()
	if (body is Character
		and not animation_player.is_playing()
		and body.velocity.y > 20):
		animation_player.play("spring")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"press":
			state = FSMState.RELEASING
		"release":
			state = FSMState.ABLE


func _on_finish_timer_timeout() -> void:
	finished.emit()
