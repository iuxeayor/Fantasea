class_name Player
extends Character

const WATERMELON_SEED: PackedScene = preload("res://src/unit/character/player/item/watermelon_seed.tscn")

signal dead

var safe_spot: Vector2 = Vector2.ZERO
var face_direction: Constant.Direction = Constant.Direction.RIGHT: # 角色朝向
		set(v):
			face_direction = v
			graphics.scale.x = -1 if face_direction == Constant.Direction.LEFT else 1
var control_direction: Constant.ControlDirection = Constant.ControlDirection.NONE # 控制方向
var interact_objects: Array[Node] = [] # 交互对象
var coyote_timer: Dictionary = {
	"ground": null,
	"wall": null,
}
var debug_point: Vector2 = Vector2.ZERO
var alive: bool = true # 是否存活

@onready var state_machine: StateMachine = $StateMachine
@onready var attack_sub_fsm: SubStateMachine = $StateMachine/AttackSubFSM
@onready var action_sub_fsm: Node = $StateMachine/AttackSubFSM/ActionSubFSM
@onready var control_manager: ControlManager = $ControlManager
@onready var throw_point: Marker2D = $Graphics/ThrowPoint
# 计时器
@onready var timers: Node = $Timers
@onready var attack_cd_timer: Timer = $Timers/AttackCdTimer
@onready var shoot_cd_timer: Timer = $Timers/ShootCdTimer
@onready var jumping_timer: Timer = $Timers/JumpingTimer
@onready var hurt_timer: Timer = $Timers/HurtTimer
@onready var drop_timer: Timer = $Timers/DropTimer
@onready var dashing_timer: Timer = $Timers/DashingTimer
@onready var dash_cd_timer: Timer = $Timers/DashCdTimer
@onready var back_safe_spot_timer: Timer = $Timers/BackSafeSpotTimer
@onready var dead_timer: Timer = $Timers/DeadTimer
@onready var dead_slow_timer: Timer = $Timers/DeadSlowTimer
@onready var hurt_slow_timer: Timer = $Timers/HurtSlowTimer
@onready var imbalance_timer: Timer = $Timers/ImbalanceTimer
@onready var auto_heal_timer: Timer = $Timers/AutoHealTimer
# 碰撞检查
@onready var hitbox: Area2D = $Graphics/Hitbox
@onready var hurtbox: Hitbox = $Graphics/Hurtbox
@onready var top_wall_checker: RayCast2D = $Graphics/Checkers/TopWallChecker
@onready var mid_wall_checker: RayCast2D = $Graphics/Checkers/MidWallChecker
@onready var bottom_wall_checker: RayCast2D = $Graphics/Checkers/BottomWallChecker
@onready var left_floor_checker: RayCast2D = $Graphics/Checkers/LeftFloorChecker
@onready var right_floor_checker: RayCast2D = $Graphics/Checkers/RightFloorChecker
@onready var mid_floor_checker: RayCast2D = $Graphics/Checkers/MidFloorChecker
@onready var front_edge_checker: RayCast2D = $Graphics/Checkers/FrontEdgeChecker
@onready var back_edge_checker: RayCast2D = $Graphics/Checkers/BackEdgeChecker
@onready var spike_checker: Area2D = $Graphics/Checkers/SpikeChecker
@onready var hit_wall_checker: RayCast2D = $Graphics/WeaponSprite/HitWallChecker
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var ice_wall_checker: RayCast2D = $Graphics/Checkers/IceWallChecker
@onready var ice_ground_checker: RayCast2D = $Graphics/Checkers/IceGroundChecker
# 提示
@onready var interact_hint: Sprite2D = $Hints/InteractHint
@onready var healing_hint: ProgressBar = $Hints/HealingHint
@onready var hit_wall_particles: ParticleQueue = $HitWallParticles
@onready var dash_particle: GPUParticles2D = $Graphics/DashParticle
@onready var wall_slide_particle: GPUParticles2D = $Graphics/WallSlideParticle
@onready var dead_particle: GPUParticles2D = $Graphics/DeadParticle
@onready var hurt_particle: GPUParticles2D = $Graphics/HurtParticle
@onready var double_jump_particle: GPUParticles2D = $Graphics/DoubleJumpParticle
@onready var dash_shield_particle: GPUParticles2D = $Graphics/DashShieldParticle
# 图像
@onready var weapon_sprite: Sprite2D = $Graphics/WeaponSprite
@onready var visible_on_screen_notifier_2d: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D

func _ready() -> void:
	animation_play("fall")
	visible_on_screen_notifier_2d.show()
	safe_spot = global_position
	# 注册西瓜籽
	Constant.register_object("watermelon_seed", WATERMELON_SEED)
	Game.register_object_pool("watermelon_seed", 10)
	# 郊狼时间计时器
	for key: String in coyote_timer.keys():
		var timer: Timer = Timer.new()
		timer.one_shot = true
		timer.wait_time = 0.1
		coyote_timer[key] = timer
		timers.add_child(timer)
	_handle_item()

func _process(_delta: float) -> void:
	if hurt_timer.is_stopped():
		return
	hurt_flash()

func _physics_process(_delta: float) -> void:
	move_and_slide()
	if InputManager.is_action_just_pressed("interact"):
		if (interact_objects.size() > 0
			and (action_sub_fsm.state_name() == "Idle"
				or action_sub_fsm.state_name() == "Run")):
			interact_objects.back().trigger()

func _handle_item() -> void:
	if Status.has_collection("stinky_tofu"):
		hurt_timer.wait_time = Constant.EXTEND_HURT_TIME
	else:
		hurt_timer.wait_time = Constant.HURT_TIME
	if Status.has_collection("straw_glasses"):
		auto_heal_timer.start(Constant.FAST_AUTO_HEAL_TIME)
		if Status.has_collection("fresh_milk"):
			auto_heal_timer.wait_time = Constant.FAST_AUTO_HEAL_TIME
		else:
			auto_heal_timer.wait_time = Constant.AUTO_HEAL_TIME
	if Status.has_collection("lemon_slice"):
		shoot_cd_timer.wait_time = Constant.FAST_SHOOT_CD_TIME
	else:
		shoot_cd_timer.wait_time = Constant.SHOOT_CD_TIME
	if Status.has_collection("hot_sauce"):
		attack_cd_timer.wait_time = Constant.FAST_ATTACK_CD_TIME
	else:
		attack_cd_timer.wait_time = Constant.ATTACK_CD_TIME
	

func animation_play_step() -> void:
	SoundManager.play_sfx("PlayerStep")

func get_status() -> Status.PlayerStatus:
	return status.to_status()
	
# 刷新操作方向
func refresh_control_direction() -> void:
	var direction: float = InputManager.get_axis("move_left", "move_right")
	if direction == 0:
		control_direction = Constant.ControlDirection.NONE
	elif direction < 0:
		control_direction = Constant.ControlDirection.LEFT
	elif direction > 0:
		control_direction = Constant.ControlDirection.RIGHT

func refresh_face_direction() -> void:
	# 根据控制方向刷新朝向
	match control_direction:
		Constant.ControlDirection.LEFT:
			face_direction = Constant.Direction.LEFT
		Constant.ControlDirection.RIGHT:
			face_direction = Constant.Direction.RIGHT

# 尝试抓墙
func catching_wall() -> bool:
	if control_direction == Constant.ControlDirection.NONE:
		return false
	return (top_wall_checker.is_colliding()
		and bottom_wall_checker.is_colliding()
		and mid_wall_checker.is_colliding()
		and control_direction * get_wall_normal().x < 0
		and Status.has_collection("honey")
		and not ice_wall_checker.is_colliding())

# 从平台落下行为
func drop_platform() -> void:
	set_collision_mask_value(2, false)
	set_collision_mask_value(16, false)
	drop_timer.start()

# 移动，纵向仅应用重力
func move(delta: float, direction: Constant.ControlDirection, speed: float, acceleration: float, gravity: float) -> void:
	# 纵向，限制最大下落速度
	velocity.y = min(velocity.y + gravity * delta, Constant.MAX_FALL_VELOCITY)
	# 横向
	var target_speed: float = direction * abs(speed)
	# 判断当前是否需要减速或变向：如果velocity.x与目标速度方向相反，则增加加速度
	var effective_acceleration: float = acceleration
	if (velocity.x > 0 and direction < 0) or (velocity.x < 0 and control_direction > 0):
		effective_acceleration *= 2
	# 在果冻上时减速
	if Game.get_game_scene().jelly.is_player_on_platform():
		target_speed /= 8
		effective_acceleration *= 8
	velocity.x = move_toward(velocity.x, target_speed, effective_acceleration * delta)

# 面向指定方向，重合时不转向
func face_to(target_location: float) -> void:
	if global_position.x < target_location:
		face_direction = Constant.Direction.RIGHT
	elif global_position.x > target_location:
		face_direction = Constant.Direction.LEFT

# 在指定的郊狼时间内
func in_coyote_time(key: String) -> bool:
	if coyote_timer.get(key) == null:
		return false
	return not coyote_timer.get(key).is_stopped()

func refresh_safe_spot() -> void:
	if (is_on_floor()
		and hurt_timer.is_stopped()
		and left_floor_checker.is_colliding()
		and right_floor_checker.is_colliding()
		and mid_floor_checker.is_colliding()
		and not spike_checker.has_overlapping_bodies()):
		safe_spot = global_position

# 击退
func hit_recoil() -> void:
	if is_on_floor():
		velocity.x = - face_direction * Constant.HIT_KNOCKBACK_HORIZONTAL_SPEED
	else:
		velocity.x = - face_direction * Constant.HIT_KNOCKBACK_HORIZONTAL_SPEED
		velocity.y = Constant.HIT_KNOCKBACK_VERTICAL_VELOCITY

# 从库存补充药水
func fill_potion() -> void:
	# 补满药水
	var need_potion: int = status.max_potion - status.potion
	if status.potion_store >= need_potion:
		status.potion_store -= need_potion
		status.potion = status.max_potion
		UIManager.status_panel.update_potion_store_info(status.potion_store, need_potion)
	else:
		var potion_count: int = status.potion_store
		status.potion += potion_count
		status.potion_store = 0
		UIManager.status_panel.update_potion_store_info(status.potion_store, potion_count)

func _on_hidden_wall_checker_body_entered(body: Node2D) -> void:
	if body is TileMapLayer:
		body.fade_out()


func _on_hidden_wall_checker_body_exited(body: Node2D) -> void:
	if body is TileMapLayer:
		body.fade_in()

func _on_healing_hint_finished() -> void:
	status.health += 1
	SoundManager.play_sfx("PlayerHeal")
	action_sub_fsm.change_state("Idle")
	if status.potion > 0:
		status.potion -= 1
	elif Status.has_collection("chicken_sandwich"):
		status.potion_store -= 2
		UIManager.status_panel.update_potion_store_info(status.potion_store, 2)
		# 物品栏显示依赖全局Status，所以需要修改
		# 糟糕的代码设计，但是耦合太深没办法了
		Status.player_status.potion_store = status.potion_store

func _on_drop_timer_timeout() -> void:
	set_collision_mask_value(2, true)
	set_collision_mask_value(16, true)

func _on_hurt_timer_timeout() -> void:
	if alive:
		hurtbox.disabled = false
	set_process(false)
	reset_flash.call_deferred()


func _on_back_safe_spot_timer_timeout() -> void:
	if not alive:
		return
	global_position = safe_spot
	collision_shape_2d.set_deferred("disabled", false)
	action_sub_fsm.change_state("Fall")
	velocity = Vector2.ZERO
		
func _on_easy_mode_timer_timeout() -> void:
	if Config.easy_mode:
		status.health += 1

func _on_interact_checker_body_entered(body: Node2D) -> void:
	if body.is_in_group("interact_object"):
		interact_objects.append(body)
	handle_interact_hint()

func _on_interact_checker_body_exited(body: Node2D) -> void:
	if body.is_in_group("interact_object"):
		interact_objects.erase(body)
	handle_interact_hint()
	
func handle_interact_hint() -> void:
	if interact_objects.size() > 0:
		interact_hint.show()
	else:
		interact_hint.hide()

func imbalance(time: float) -> void:
	if (state_machine.state_name() == "AttackSubFSM"
		and attack_sub_fsm.state_name() == "ActionSubFSM"):
		match action_sub_fsm.state_name():
			"Idle", "Run", "WallSlide":
				imbalance_timer.wait_time = time
				state_machine.change_state("Imbalance")

func can_heal() -> bool:
	return (status.health < status.max_health
		and (status.potion > 0
		or (Status.has_collection("chicken_sandwich")
		and status.potion_store >= 2)))

func _on_hurtbox_collided(source: Hitbox.CollideSource, damage: int, location: Vector2) -> void:
	if state_machine.state_name() == "Hurt":
		return
	var desire_damage: int = damage
	var defended: bool = false ## 冻苹果防御标记
	var explosion: bool = false ## 蘑菇粉爆炸标记
	# 拥有冻苹果时，冲刺免疫正面地形外的伤害
	if (Status.has_collection("frozen_apple")
		and attack_sub_fsm.state_name() == "Dash"
		and source != Hitbox.CollideSource.ENVIRONMENT
		and ((face_direction == Constant.Direction.RIGHT
			and location.x > global_position.x)
			or (face_direction == Constant.Direction.LEFT
			and location.x < global_position.x))):
		desire_damage = 0
		defended = true
	match source:
		Hitbox.CollideSource.ENVIRONMENT:
			if Config.easy_mode:
				desire_damage = 0
			else:
				desire_damage = 1
			collision_shape_2d.set_deferred("disabled", true)
			back_safe_spot_timer.start()
		Hitbox.CollideSource.ENEMY:
			if Config.easy_mode:
				desire_damage = min(desire_damage, 1)
			# 伤害来源方向
			if location.x > global_position.x:
				face_direction = Constant.Direction.RIGHT
			elif location.x < global_position.x:
				face_direction = Constant.Direction.LEFT
			if Status.has_collection("mushroom_powder"):
				explosion = true
		Hitbox.CollideSource.BULLET:
			if Config.easy_mode:
				desire_damage = 0
			# 伤害来源方向
			if location.x > global_position.x:
				face_direction = Constant.Direction.RIGHT
			elif location.x < global_position.x:
				face_direction = Constant.Direction.LEFT
	status.health -= desire_damage
	if status.health <= 0:
		dead.emit()
		state_machine.change_state("Die")
	else:
		if defended:
			state_machine.change_state("DashShield")
		else:
			if explosion:
				Game.get_game_scene().powder_explosion.spawn(
					global_position + Vector2(0, -8), status.attack + status.max_health - status.health)
			state_machine.change_state("Hurt")
		

func _on_status_status_changed(type_name: StringName, value: Variant) -> void:
	if type_name == "attack":
		hitbox.damage = value


func _on_refresh_safe_spot_timer_timeout() -> void:
	refresh_safe_spot()


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	if not alive and velocity.y >= 0:
		dead_timer.start()


func _on_dead_timer_timeout() -> void:
	Engine.time_scale = Config.game_speed
	Game.load_game(Game.save_name)


func _on_dead_slow_timer_timeout() -> void:
	Engine.time_scale = Config.game_speed


func _on_hurt_slow_timer_timeout() -> void:
	if not alive:
		return
	Engine.time_scale = Config.game_speed


func _on_auto_heal_timer_timeout() -> void:
	if (Status.has_collection("straw_glasses")
		and status.health < status.max_health
		and status.potion > 1):
		status.health += 1
		status.potion -= 1
		SoundManager.play_sfx("PlayerHeal")
		auto_heal_timer.start()
