extends CharacterBullet

const MAX_ROTATION: float = 6
const TRACK_TIME: float = 1.5
const SPEED: float = 200

var max_rotation: float = MAX_ROTATION
var action_tween: Tween = null


func _physics_process(delta: float) -> void:
	super(delta)
	var desired_angle: float = global_position.direction_to(Game.get_player().global_position).angle()
	var angle_diff: float = lerp_angle(rotation, desired_angle, max_rotation * delta)
	velocity = Vector2.RIGHT.rotated(angle_diff) * SPEED

func spawn(location: Vector2, velo: Vector2) -> void:
	super(location, velo)
	max_rotation = MAX_ROTATION
	action_tween = create_tween()
	action_tween.tween_property(self, "max_rotation", 0, TRACK_TIME)

func dead() -> void:
	if action_tween != null and action_tween.is_running():
		action_tween.kill()
	super()
