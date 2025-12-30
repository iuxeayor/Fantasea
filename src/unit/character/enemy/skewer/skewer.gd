extends Enemy

@onready var attack_checker: RayCast2D = $Graphics/AttackChecker
@onready var front_player_checker: RayCast2D = $Graphics/FrontPlayerChecker
@onready var top_player_checker: RayCast2D = $Graphics/TopPlayerChecker
@onready var hit_wall_particle: GPUParticles2D = $Graphics/HitWallParticle
@onready var left_attack_collision: CollisionShape2D = $LeftAttackCollision
@onready var right_attack_collision: CollisionShape2D = $RightAttackCollision
@onready var turn_cd_timer: Timer = $Timers/TurnCDTimer

func die() -> void:
	super ()
	left_attack_collision.set_deferred("disabled", true)
	right_attack_collision.set_deferred("disabled", true)
