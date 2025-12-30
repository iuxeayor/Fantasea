@tool
extends Node2D

const DOT_RADIUS: float = 8.0
const MOVE_DEADZONE: float = 0.2
const DROP_DEADZONE: float = 0.5
const NORMAL_COLOR: Color = Color(1, 1, 1, 0.5)

@export_range(8, 48, 1) var radius: float = 32:
	set(v):
		radius = clampf(v, 8, 48)
		if Engine.is_editor_hint():
			queue_redraw()

var finger_index: int = -1

var joystick_movement: Vector2 = Vector2.ZERO

@onready var original_position: Vector2 = global_position

@onready var dot: Node2D = $Dot

func _ready() -> void:
	modulate = NORMAL_COLOR
	queue_redraw()

func _input(event: InputEvent) -> void:
	if (not Util.is_touchscreen_platform()
		or not is_visible_in_tree()):
		return
	if not (event is InputEventScreenDrag or event is InputEventScreenTouch):
		return
	# 不在游戏场景中时不处理
	if Game.get_game_scene() == null:
		return
	# 开启菜单时不处理
	if UIManager.menu_screen.visible or UIManager.inventory_screen.visible:
		return
	if event is InputEventScreenTouch:
		# 处理手指检测
		if event.pressed:
			if finger_index == -1:
				if event.position.distance_to(original_position) < radius:
					finger_index = event.index
					modulate = NORMAL_COLOR
		else:
			if event.index == finger_index:
				finger_index = -1
				if Input.is_action_pressed("move_left"):
					Input.action_release.call_deferred("move_left")
				if Input.is_action_pressed("move_right"):
					Input.action_release.call_deferred("move_right")
				if Input.is_action_pressed("drop"):
					Input.action_release.call_deferred("drop")
				dot.set_deferred("position", Vector2.ZERO)
				return
	# 判断是否是当前手指
	if event.index != finger_index:
		return
	# 触摸事件
	dot.position = (event.position - original_position).limit_length(radius)
	joystick_movement = dot.position / radius
	# 左右移动
	if joystick_movement.x > MOVE_DEADZONE:
		if Input.is_action_pressed("move_left"):
			Input.action_release("move_left")
		Input.action_press("move_right")
	elif joystick_movement.x < -MOVE_DEADZONE:
		if Input.is_action_pressed("move_right"):
			Input.action_release("move_right")
		Input.action_press("move_left")
	else:
		if Input.is_action_pressed("move_left"):
			Input.action_release("move_left")
		if Input.is_action_pressed("move_right"):
			Input.action_release("move_right")
	if joystick_movement.y > DROP_DEADZONE:
		Input.action_press("drop")
	else:
		if Input.is_action_pressed("drop"):
			Input.action_release("drop")

func update(pos: Vector2, rad: float) -> void:
	position = pos
	original_position = global_position
	radius = rad
	queue_redraw()

func _draw() -> void:
	# 圆环
	draw_arc(
		Vector2.ZERO,
		radius,
		0,
		TAU,
		32,
		Color.WHITE,
		1,
	)
	# 移动死区
	var move_x: float = radius * MOVE_DEADZONE
	var move_y: float = radius * sqrt(1 - (MOVE_DEADZONE * MOVE_DEADZONE)) - 2
	draw_dashed_line(
		Vector2(-move_x, -move_y), 
		Vector2(-move_x, move_y), 
		Color.WHITE, 
		0.5)
	draw_dashed_line(
		Vector2(move_x, -move_y), 
		Vector2(move_x, move_y), 
		Color.WHITE, 
		0.5)
	# 下落死区
	var drop_y: float = radius * DROP_DEADZONE
	var drop_x: float = radius * sqrt(1 - (DROP_DEADZONE * DROP_DEADZONE)) - 2
	draw_dashed_line(
		Vector2(-drop_x, drop_y), 
		Vector2(drop_x, drop_y), 
		Color.WHITE, 
		0.5)
