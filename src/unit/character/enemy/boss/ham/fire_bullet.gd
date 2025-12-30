extends CharacterBullet

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var spawn_animation_player: AnimationPlayer = $SpawnAnimationPlayer
@onready var flame_timer: Timer = $FlameTimer
@onready var start_particle: GPUParticles2D = $StartParticle
@onready var smoke_particle: GPUParticles2D = $SmokeParticle

func _ready() -> void:
	super()
	flame_timer.wait_time = life_timer.wait_time - spawn_animation_player.get_animation("end").length

func spawn(location: Vector2, velo: Vector2) -> void:
	super(location, velo)
	animation_player.play("flame")
	SoundManager.play_sfx("Fire")
	flame_timer.start()
	spawn_animation_player.play("start")
	smoke_particle.restart()
	start_particle.restart()
	
func _on_flame_timer_timeout() -> void:
	spawn_animation_player.play("end")

func dead() -> void:
	smoke_particle.emitting = false
	super()
