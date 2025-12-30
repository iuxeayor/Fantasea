@tool
extends Area2D
class_name Teleporter

@export var vertical: bool = true: ## 是否为垂直，基于所在边缘决定
	set(v):
		vertical = v
		if Engine.is_editor_hint() and is_node_ready():
			if vertical:
				vertical_collision.show()
				horizontal_collision.hide()
			else:
				vertical_collision.hide()
				horizontal_collision.show()
		
@export var target_scene: int = 0 ## 跳转目标场景
@export var target_entry_point: Constant.EntryPoint = Constant.EntryPoint.LEFT ## 跳转目标场景的入口

@onready var vertical_collision: CollisionShape2D = $VerticalCollision
@onready var horizontal_collision: CollisionShape2D = $HorizontalCollision


# 用于切换场景时计算玩家相对位置
var sub_entry_point: EntryPoint = null

func _ready() -> void:
	if Engine.is_editor_hint():
		if vertical:
			vertical_collision.show()
			horizontal_collision.hide()
		else:
			vertical_collision.hide()
			horizontal_collision.show()
	if vertical:
		vertical_collision.set_deferred("disabled", false)
		horizontal_collision.set_deferred("disabled", true)
	else:
		vertical_collision.set_deferred("disabled", true)
		horizontal_collision.set_deferred("disabled", false)
	if get_node_or_null("EntryPoint") != null:
		sub_entry_point = get_node("EntryPoint")

func _on_body_entered(_body: Node2D) -> void:
	var player: Player = Game.get_player()
	var edge: Rect2i = Game.get_game_scene().block_edge
	var entry_offset: Vector2 = Vector2.ZERO
	# 没有子入口时不计算
	if sub_entry_point != null:
		# 判断该入口是左右侧的还是上下侧的
		# 用于在传送后保留玩家的相对位置，比如跳跃时会从高处进入另一个场景
		# 左右侧的，计算玩家y相对位置
		if (abs(sub_entry_point.global_position.x - edge.position.x) < 1
			or abs(sub_entry_point.global_position.x - edge.end.x) < 1):
				entry_offset.y = player.global_position.y - sub_entry_point.global_position.y
		# 上下侧的，计算玩家x相对位置
		if (abs(sub_entry_point.global_position.y - (edge.position.y + 8)) < 1
			or abs(sub_entry_point.global_position.y - (edge.end.y + 8)) < 1):
				entry_offset.x = player.global_position.x - sub_entry_point.global_position.x
	Game.get_game_scene().to_status()
	var switch_info: Status.SwitchSceneInfo = Status.SwitchSceneInfo.new()
	switch_info.entry_point = target_entry_point
	switch_info.entry_offset = entry_offset
	switch_info.direction = player.face_direction
	switch_info.velocity.x = clampf(player.velocity.x, -Constant.MIN_DASH_SPEED, Constant.MIN_DASH_SPEED) # 最大速度不超过移速、
	switch_info.velocity.y = clampf(player.velocity.y, Constant.MAX_JUMP_VELOCITY, Constant.MAX_FALL_VELOCITY) # 最大速度不超过跳跃速度
	Game.normal_switch_game_scene(target_scene, switch_info)
