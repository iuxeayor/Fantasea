extends Boss


var dash_target: Vector2 = global_position

@onready var drop_particle: ParticleQueue = $DropParticle
@onready var dash_particle: GPUParticles2D = $Graphics/DashParticle
@onready var wall_checker: RayCast2D = $Graphics/WallChecker
@onready var trail: Trail = $Trail
@onready var hitbox_collision: CollisionShape2D = $Graphics/Hitbox/CollisionShape2D

func _ready() -> void:
	super()
	trail.hide()

func animation_play_attack_1() -> void:
	SoundManager.play_sfx("ButterAttack1")

func animation_play_attack_2() -> void:
	SoundManager.play_sfx("ButterAttack2")

func animation_play_attack_3() -> void:
	SoundManager.play_sfx("ButterAttack3")

func hurt(damage: int) -> void:
	super(damage)
	hurt_particle.trigger(sprite_2d.global_position)
	if status.health <= 0:
		stop_battle()
		defeated.emit()
