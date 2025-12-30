@tool
extends StaticBody2D

signal opened
signal completed

enum DisplayDirection {
	UP,
	RIGHT,
	DOWN,
	LEFT
}

@export var direction: DisplayDirection = DisplayDirection.UP:
	set(v):
		direction = v
		if Engine.is_editor_hint():
			match direction:
				DisplayDirection.UP:
					graphic.rotation = 0
				DisplayDirection.RIGHT:
					graphic.rotation = PI / 2
				DisplayDirection.DOWN:
					graphic.rotation = PI
				DisplayDirection.LEFT:
					graphic.rotation = -PI / 2

@export var mech: Node2D ## 绑定的机关
@export var extra_mech: Array[Node2D] = [] ## 额外绑定的机关
@export var delay_time: float = 0: ## 等待时间，为0时为非计时
	set(v):
		delay_time = max(0, v)
		is_timer_mode = delay_time > 0
		if Engine.is_editor_hint():
			if delay_time > 0:
				ball.frame = 2
			else:
				ball.frame = 0

var is_timer_mode: bool = false ## 计时模式

@onready var ball: Sprite2D = $Graphic/Ball
@onready var graphic: Node2D = $Graphic
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var timer: Timer = $Timer
@onready var short_timer: Timer = $ShortTimer
@onready var tick_timer: Timer = $TickTimer
@onready var hitbox: Hitbox = $Hitbox

func _ready() -> void:
	match direction:
		DisplayDirection.UP:
			graphic.rotation = 0
		DisplayDirection.RIGHT:
			graphic.rotation = PI / 2
		DisplayDirection.DOWN:
			graphic.rotation = PI
		DisplayDirection.LEFT:
			graphic.rotation = -PI / 2
	if is_timer_mode:
		ball.frame = 2
	else:
		ball.frame = 0
		await owner.ready
	# 绑定机关，基于第一个机关的完成信号
	if mech.only_open:
		mech.finished.connect(func() -> void:
			completed.emit()
		)
	else:
		if not is_timer_mode:
			mech.finished.connect(_switch_mode_restore)

func complete() -> void:
	hitbox.disabled = true
	ball.frame = 1
	if mech.only_open:
		mech.complete()
	else:
		mech.open()
	for mech_node: Node2D in extra_mech:
		if mech_node.only_open:
			mech_node.complete()
		else:
			mech_node.open()

# 切换模式，触发启动机关
func _switch_mode() -> void:
	hitbox.disabled = true
	ball.frame = 1
	if mech.opened:
		mech.close()
	else:
		mech.open()
	for mech_node: Node2D in extra_mech:
		if mech_node.opened:
			mech_node.close()
		else:
			mech_node.open()

# 恢复触发
func _switch_mode_restore() -> void:
	hitbox.disabled = false
	ball.frame = 0

func _timer_mode() -> void:
	hitbox.disabled = true # 结束前无法触发
	# 计时
	short_timer.start(max(0.1, delay_time - 2))
	timer.start(delay_time)
	tick_timer.start() # 短延时用于在即将结束时触发动画
	ball.set_deferred("frame", 3)
	mech.open()
	for mech_node: Node2D in extra_mech:
		mech_node.open()

func play_tick() -> void:
	SoundManager.play_sfx("SwitchBallTick")
	
func _on_hitbox_collided(source: Hitbox.CollideSource, _damage: int, _location: Vector2) -> void:
	if source == Hitbox.CollideSource.PLAYER:
		SoundManager.play_sfx("SwitchBallSwitch")
		animation_player.play("hit")
		if is_timer_mode:
			_timer_mode()
		else:
			_switch_mode()
		opened.emit()


func _on_timer_timeout() -> void:
	animation_player.stop()
	hitbox.disabled = false
	ball.set_deferred("frame", 2)
	mech.close()
	for mech_node: Node2D in extra_mech:
		if mech_node.opened:
			mech_node.close()
	

func _on_short_timer_timeout() -> void:
	animation_player.play("alert")


func _on_tick_timer_timeout() -> void:
	if short_timer.is_stopped():
		return
	tick_timer.start()
	play_tick()
