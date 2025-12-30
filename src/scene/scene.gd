class_name Scene
extends Node2D

@export var scene_environment: Constant.SceneEnvironment = Constant.SceneEnvironment.SWAP
@export var bgm: AudioStreamOggVorbis = null ## 场景bgm
@export var scene_name: String = "" ## 场景名
@export var explore_unit: Node = null ## 影响场景状态的单位
@export var units_can_change: Array[Node2D] = [] ## 场景探索完毕后有变化的单位
@export var custom_explore: bool = false ## 自定义场景探索

# 场景探索状态
var explore_status: Constant.ExploreStatus = Constant.ExploreStatus.UNKNOWN
@onready var units: Node2D = $Units
@onready var enemies: Node2D = $Units/Enemies
@onready var object_pool: ObjectPool = $Units/ObjectPool
@onready var game_tile: TileMapLayer = $GameTile
@onready var player: Player = $Player
@onready var game_camera: Camera2D = $GameCamera
@onready var camera_remote: RemoteTransform2D = $Player/CameraRemote
@onready var jelly: CharacterBody2D = $Units/Jelly
@onready var powder_explosion: Node2D = $Units/PowderExplosion
@onready var web_loader: Node2D = $Background/Environment/WebLoader

var block_start: Vector2i = Vector2i.ZERO
var block_end: Vector2i = Vector2i.ONE
var block_edge: Rect2i = Rect2i(0, 0, 1, 1)
var web_exist_resource: Array[String] = []

# 掉落物资源
var loots: Dictionary = {
	Constant.Loot.COIN_1: preload("res://src/unit/loot/coin_1.tscn"),
	Constant.Loot.COIN_10: preload("res://src/unit/loot/coin_10.tscn"),
	Constant.Loot.COIN_100: preload("res://src/unit/loot/coin_100.tscn"),
	Constant.Loot.MILK: preload("res://src/unit/loot/milk.tscn")
}

func _ready() -> void:
	# 游戏处理
	Engine.time_scale = Config.game_speed # 恢复游戏速度
	UIManager.touchscreen.try_show() # 移动端时显示触摸屏
	SoundManager.night_bgm(not Status.scene_status.story.get("main_sleep", false))
	if bgm != null:
		SoundManager.play_bgm.call_deferred(bgm) # 延迟播放bgm
	else:
		SoundManager.stop_bgm()
		SoundManager.stop_all_loop_sfx()
	UIManager.change_theme_by_scene(scene_environment) # 切换主题为当前场景主题
	UIManager.status_panel.show()
	UIManager.status_panel.boss_health_bar_container.hide()
	# 场景处理
	_cal_block() # 计算区块
	explore_status = Constant.ExploreStatus.EXPLORED
	from_status()
	_handle_explore_unit()
	_limit_camera()
	# 延展仅在移动设备上生效
	if Util.is_touchscreen_platform():
		get_viewport().size_changed.connect(_limit_camera)
	_before_ready()
	_web_preload(units) # web平台额外加载一些资源
	Game.new_scene_ready.emit()
	

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("menu"):
		get_viewport().set_input_as_handled()
		UIManager.menu_screen.opening = true
		UIManager.menu_screen.current_menu = Constant.GameMenu.IN_GAME
	elif event.is_action_pressed("inventory") and not InputManager.disabled:
		get_viewport().set_input_as_handled()
		UIManager.inventory_screen.opening = true
	# debug按键
	_debug_action(event)
	
# 调试按键
func _debug_action(event: InputEvent) -> void:
	if Game.is_debugging:
		if event.is_action_pressed("debug_0"):
			# 传送玩家到鼠标位置
			get_viewport().set_input_as_handled()
			player.global_position = get_global_mouse_position()
		elif event.is_action_pressed("debug_1"):
			# 解锁所有玩家能力
			get_viewport().set_input_as_handled()
			player.status.attack = 8
			player.status.money += 100
			Status.player_status.money += 1
			Status.player_status.number_collection["health_chip"] = 9
			Status.player_status.number_collection["weapon_level"] = 3
			Status.player_status.number_collection["potion"] = 5
			for collection_name: StringName in Status.player_status.collection.keys():
				Status.player_status.collection[collection_name] = true
			
		elif event.is_action_pressed("debug_2"):
			# 解锁地图
			for i in range(Status.scene_status.scene_explore.size()):
				Status.scene_status.scene_explore[i] = Constant.ExploreStatus.COMPLETE
		elif event.is_action_pressed("debug_3"):
			# 清除地图
			for i in range(Status.scene_status.scene_explore.size()):
				Status.scene_status.scene_explore[i] = Constant.ExploreStatus.UNKNOWN
		elif event.is_action_pressed("debug_4"):
			# 减少药水上限
			get_viewport().set_input_as_handled()
			player.status.max_potion -= 1
		elif event.is_action_pressed("debug_5"):
			# 增加药水上限
			get_viewport().set_input_as_handled()
			player.status.max_potion += 1
		elif event.is_action_pressed("debug_6"):
			# 补满药水
			get_viewport().set_input_as_handled()
			player.status.potion = player.status.max_potion
		elif event.is_action_pressed("debug_7"):
			# 减少生命上限
			get_viewport().set_input_as_handled()
			player.status.max_health -= 1
		elif event.is_action_pressed("debug_8"):
			# 增加生命上限
			get_viewport().set_input_as_handled()
			player.status.max_health += 1
		elif event.is_action_pressed("debug_9"):
			# 补满生命
			get_viewport().set_input_as_handled()
			player.status.health = player.status.max_health

# 继承场景在此处做最后处理
func _before_ready() -> void:
	pass

func _cal_block() -> void:
	# 根据已用像素范围，向区块对齐（取最小、最大区块索引）
	var screen_width: int = ProjectSettings.get_setting("display/window/size/viewport_width")
	var screen_height: int = ProjectSettings.get_setting("display/window/size/viewport_height")
	var used_rect: Rect2 = Rect2(
		game_tile.get_used_rect().position.x * game_tile.tile_set.tile_size.x,
		game_tile.get_used_rect().position.y * game_tile.tile_set.tile_size.y,
		game_tile.get_used_rect().size.x * game_tile.tile_set.tile_size.x,
		game_tile.get_used_rect().size.y * game_tile.tile_set.tile_size.y
	)
	block_start = Vector2i(
		int(used_rect.position.x / screen_width),
		int(used_rect.position.y / screen_height)
	)
	block_end = Vector2i(
		int(used_rect.end.x / screen_width),
		int(used_rect.end.y / screen_height)
	)
	block_edge.position = Vector2i(block_start.x * screen_width, block_start.y * screen_height)
	block_edge.end = Vector2i(block_end.x * screen_width, block_end.y * screen_height)

# 限制相机范围
func _limit_camera() -> void:
	game_camera.limit_left = block_edge.position.x
	game_camera.limit_top = block_edge.position.y
	game_camera.limit_right = block_edge.end.x
	game_camera.limit_bottom = block_edge.end.y
	# 延展仅在移动设备上生效
	if Util.is_touchscreen_platform():
		var screen_width: int = ProjectSettings.get_setting("display/window/size/viewport_width")
		var screen_height: int = ProjectSettings.get_setting("display/window/size/viewport_height")
		var base_ratio: float = float(screen_width) / float(screen_height)
		var screen_size: Vector2 = get_viewport().get_visible_rect().size
		var screen_ratio: float = screen_size.x / screen_size.y
		if screen_ratio > base_ratio:
			var expand: int = roundi((screen_size.x - screen_size.y * base_ratio) / 2)
			game_camera.limit_left -= expand
			game_camera.limit_right += expand
		elif screen_ratio < base_ratio:
			var expand: int = roundi((screen_size.y - screen_size.x / base_ratio) / 2)
			game_camera.limit_top -= expand
			game_camera.limit_bottom += expand

func _web_preload(search_node: Node) -> void:
	# 网页版粒子缓存功能不全，会导致粒子首次使用时卡顿
	# 所以用在加载场景时预加载场景中所有粒子，以切换场景卡顿为代价，提升游戏中流畅度
	if not Util.is_web_platform():
		return
	var node_queue: Array[Node] = [search_node]
	while node_queue.size() > 0:
		var current: Node = node_queue.pop_front()  # 取出队首元素
		if current is GPUParticles2D:
			if not web_exist_resource.has(current.process_material.resource_path):
				web_exist_resource.append(current.process_material.resource_path)
				var temp_particle: GPUParticles2D = GPUParticles2D.new()
				temp_particle.process_material = current.process_material
				temp_particle.lifetime = 0.1
				temp_particle.one_shot = true
				temp_particle.emitting = true
				web_loader.add_child(temp_particle)
		for child: Node in current.get_children():
			node_queue.append(child)

func get_scene_index() -> int:
	return String(name).substr(5).to_int()

# 处理探索单位
func _handle_explore_unit() -> void:
	# 自定义探索的场景不适用于常规处理
	if custom_explore:
		return
	if explore_unit != null:
		if explore_unit not in units_can_change:
			units_can_change.append(explore_unit)
		explore_unit.completed.connect(
			func() -> void:
				explore_status = Constant.ExploreStatus.COMPLETE
		)
	else:
		# 没有探索单位，直接完成
		explore_status = Constant.ExploreStatus.COMPLETE
	# 已经探索完的情况
	if explore_status == Constant.ExploreStatus.COMPLETE:
		for unit: Node2D in units_can_change:
			if unit != null:
				if unit.has_method("complete"):
					unit.complete()
				else:
					unit.queue_free()
	
	
func from_status() -> void:
	for enemy: Character in enemies.get_children():
		if (enemy.is_in_group("enemy")
			and Status.scene_enemy_data.has(name)
			and enemy.name not in Status.scene_enemy_data[name]):
			enemy.queue_free()
	if Status.scene_status.scene_explore.get(
		get_scene_index(), Constant.ExploreStatus.UNKNOWN) == Constant.ExploreStatus.COMPLETE:
		explore_status = Constant.ExploreStatus.COMPLETE
	# 子项状态
	player.status.from_status(Status.player_status)

func to_status() -> void:
	player.status.to_status()
	# 场景信息
	Status.scene_status.scene_index = get_scene_index()
	Status.scene_status.scene_explore[get_scene_index()] = explore_status
	Status.scene_status.scene_environment = scene_environment
	# 敌怪状态
	var alive_enemy: Array[String] = []
	for enemy in enemies.get_children():
		if (enemy.is_in_group("enemy")
			and enemy.alive):
			alive_enemy.append(enemy.name)
	Status.scene_enemy_data[name] = alive_enemy

# 掉落战利品
func drop_loot(location: Vector2, item: Constant.Loot, count: int) -> void:
	# 最多掉落100个
	count = min(count, 100)
	for i: int in range(count):
		var loot: PhysicsBody2D = loots.get(item, Constant.Loot.COIN_1).instantiate()
		loot.global_position = location
		units.add_child.call_deferred(loot)

func get_player_position_ratio() -> Vector2:
	var screen_size: Vector2 = Vector2(
		ProjectSettings.get_setting("display/window/size/viewport_width"),
		ProjectSettings.get_setting("display/window/size/viewport_height")
	)
	var origin: Vector2 = Vector2(block_start) * screen_size
	var region: Vector2 = (Vector2(block_end) - Vector2(block_start)) * screen_size
	var fix_player_x: float = clampf(player.global_position.x, origin.x, origin.x + region.x)
	var fix_player_y: float = clampf(player.global_position.y, origin.y, origin.y + region.y) - 8
	return (Vector2(fix_player_x, fix_player_y) - origin) / region

func _on_jelly_finished() -> void:
	player.control_manager.set_deferred("threw_jelly", false)

func is_out_of_bounds(node_pos: Vector2) -> bool:
	return (node_pos.x < block_edge.position.x - 16
		or node_pos.x > block_edge.end.x + 16
		or node_pos.y < block_edge.position.y - 16
		or node_pos.y > block_edge.end.y + 16)


func _on_object_pool_load_finished() -> void:
	_web_preload(object_pool)
