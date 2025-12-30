extends Boss

@onready var roll_particle: GPUParticles2D = $Graphics/RollParticle
@onready var land_particle: GPUParticles2D = $LandParticle
@onready var wall_checker: RayCast2D = $Graphics/WallChecker
@onready var hit_wall_particle: GPUParticles2D = $Graphics/HitWallParticle

func gravity_move(delta: float) -> void:
	velocity.y += gravity * delta

func hurt(damage: int) -> void:
	super(damage)
	hurt_particle.trigger(sprite_2d.global_position)
	if status.health <= 0:
		stop_battle()
		defeated.emit()

func _on_status_status_changed(_type_name: StringName, _value: Variant) -> void:
	UIManager.status_panel.update_boss_health(status.health, status.max_health)
