extends Character
class_name Boss

signal defeated

@export var direction: Constant.Direction = Constant.Direction.LEFT: ## 出生朝向
	set(v):
		direction = v
		if not is_node_ready():
			await ready
		graphics.scale.x = direction

var gravity: float = Constant.gravity 
var battle_stage: int = 0 # 战斗阶段

@onready var hurt_timer: Timer = $HurtTimer
@onready var hitbox: Hitbox = $Graphics/Hitbox
@onready var hurtbox: Hitbox = $Graphics/Hurtbox
@onready var behavior_tree: RootNode = $BehaviorTree
@onready var hurt_particle: ParticleQueue = $HurtParticle

func _ready() -> void:
	animation_player.play("idle")
	hitbox.disabled = true
	hurtbox.disabled = true
	behavior_tree.disabled = true

func _process(_delta: float) -> void:
	if hurt_timer.is_stopped():
		return
	hurt_flash()

func _physics_process(delta: float) -> void:
	gravity_move(delta)
	move_and_slide()

func gravity_move(delta: float) -> void:
	velocity.y += gravity * delta

func _register_object(obj_name: StringName, resource: Resource, count: int) -> void:
	Constant.register_object(obj_name, resource)
	Game.register_object_pool(obj_name, count)

func start_battle() -> void:
	hitbox.disabled = false
	hurtbox.disabled = false
	behavior_tree.disabled = false
	Game.get_player().dead.connect(_win, CONNECT_ONE_SHOT)

# 击败玩家后的行为，主要防止同归于尽的冲突
func _win() -> void:
	hitbox.disabled = true
	hurt_timer.stop()
	reset_flash.call_deferred()

func stop_battle() -> void:
	behavior_tree.reset()
	behavior_tree.disabled = true
	hitbox.disabled = true
	hurtbox.disabled = true
	hurt_timer.stop()
	reset_flash.call_deferred()

func hurt(damage: int) -> void:
	SoundManager.play_sfx("EnemyHit")
	status.health -= damage
	hurt_timer.start()
	set_process(true)
	hurtbox.disabled = true

func _on_hurt_timer_timeout() -> void:
	if status.health > 0:
		hurtbox.disabled = false
	set_process(false)
	reset_flash.call_deferred()

func _on_hurtbox_collided(source: Hitbox.CollideSource, damage: int, _location: Vector2) -> void:
	if (source == Hitbox.CollideSource.PLAYER
		and hurt_timer.is_stopped()):
		hurt(damage)

func _on_status_status_changed(_type_name: StringName, _value: Variant) -> void:
	UIManager.status_panel.update_boss_health(status.health, status.max_health)

func _pass() -> void:
	defeated.emit()
