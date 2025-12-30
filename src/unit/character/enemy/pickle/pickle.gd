extends Enemy

@onready var player_checker: RayCast2D = $PlayerChecker
@onready var break_particle: GPUParticles2D = $BreakParticle

var sleeping: bool = true

func _ready() -> void:
	super()
	behavior_tree.disabled = true
	gravity = 0
	animation_play("sleep")

func _physics_process(delta: float) -> void:
	super(delta)
	if sleeping:
		if (player_checker.is_colliding()
			and player_checker.get_collider() is Player):
			sleeping = false
			behavior_tree.disabled = false
			falling = true
			gravity = Constant.gravity
			
func hurt(damage: int, damage_direction: Constant.Direction) -> void:
	super(damage, damage_direction)
	if sleeping:
		sleeping = false
		behavior_tree.disabled = false
		falling = true
		break_particle.restart()
		SoundManager.play_sfx("PickleBreak")
		gravity = Constant.gravity

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "bounce":
		animation_play("idle")
