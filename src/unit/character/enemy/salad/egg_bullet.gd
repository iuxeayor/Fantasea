extends CharacterBullet

@onready var player_checker: RayCast2D = $PlayerChecker

var triggered: bool = false

func _physics_process(delta: float) -> void:
	super(delta)
	if (not triggered
		and player_checker.is_colliding()
		and player_checker.get_collider() is Player):
		triggered = true
		velocity.x = 0
		velocity.y = max(velocity.y, 0)
		gravity = 1800

func spawn(location: Vector2, velo: Vector2) -> void:
	super(location, velo)
	triggered = false
