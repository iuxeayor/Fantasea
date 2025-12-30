extends Node

signal new_scene_ready

const VERSION: Array[int] = [0, 0, 0]


const SAVE_PATH: String = "user://save/%s.sav"
const SAVE_PATH_DIR: String = "user://save/"
const SAVE_BACKUP_PATH_DIR: String = "user://save/backup/"

var is_debugging: bool = true # 调试模式
# 存档名
var save_name: StringName = "save0"

# 后台加载对象相关
var object_pool_request: Array[ObjectPool.Request] = []

@onready var scene_loader: Node = $SceneLoader

func _ready() -> void:
	# 检查存档目录
	if not DirAccess.dir_exists_absolute(SAVE_PATH_DIR):
		DirAccess.make_dir_absolute(SAVE_PATH_DIR)
	if not DirAccess.dir_exists_absolute(SAVE_BACKUP_PATH_DIR):
		DirAccess.make_dir_absolute(SAVE_BACKUP_PATH_DIR)
	# 触屏使用延展模式
	if Util.is_touchscreen_platform():
		get_window().content_scale_aspect = Window.CONTENT_SCALE_ASPECT_EXPAND

func start_game() -> void:
	get_tree().paused = true
	await UIManager.special_effect.fade_in(1)
	Status.reset_status()
	UIManager.inventory_screen.reset()
	SoundManager.stop_bgm()
	await switch_game_scene(1)
	Status.save_to_file(save_name)
	get_game_scene().play_story()

func load_game(sav_name: String) -> void:
	get_tree().paused = true
	await UIManager.special_effect.fade_in(1)
	# 去除其它场景效果
	UIManager.special_effect.movie_out(0)
	SoundManager.stop_all_loop_sfx()
	SoundManager.stop_bgm()
	SoundManager.night_bgm(false)
	# 数据处理
	UIManager.inventory_screen.reset()
	Status.reset_status()
	Status.load_from_file(sav_name)
	UIManager.inventory_screen.item_container.update(Status.player_status)
	UIManager.inventory_screen.map_container.mini_map.update(Status.scene_status.scene_explore)
	# 切换场景
	await switch_game_scene(Status.scene_status.scene_index)
	# 处理玩家位置
	var game_camera: Camera2D = get_game_scene().game_camera
	game_camera.position_smoothing_enabled = false
	var player: Player = get_player()
	player.fill_potion()
	player.state_machine.disabled = true
	for save_point: SavePoint in get_tree().get_nodes_in_group("save_point"):
		player.face_direction = save_point.player_direction
		break
	for entry_point: EntryPoint in get_tree().get_nodes_in_group("entry_point"):
		if entry_point.location == Constant.EntryPoint.CENTER:
			player.global_position = entry_point.global_position
	game_camera.global_position = player.global_position
	get_tree().paused = false
	game_camera.set_deferred("position_smoothing_enabled", true)
	# 播放醒来动画
	player.animation_play("sleeping")
	await get_tree().process_frame
	UIManager.special_effect.cover_out()
	await UIManager.special_effect.fade_out(1)
	player.animation_play("awake")
	await player.animation_player.animation_finished
	# 恢复控制
	player.state_machine.disabled = false
	InputManager.disabled = false

# 一般切换场景，将场景黑屏，加载后恢复
func normal_switch_game_scene(scene_index: int, switch_info: Status.SwitchSceneInfo) -> void:
	await UIManager.special_effect.cover_in()
	get_tree().paused = true
	await switch_game_scene(scene_index)
	# 处理玩家位置
	# 暂停相机平滑
	var game_camera: Camera2D = get_game_scene().game_camera
	game_camera.position_smoothing_enabled = false
	var player: Player = get_player()
	player.velocity = switch_info.velocity
	player.face_direction = switch_info.direction
	for entry_point: EntryPoint in get_tree().get_nodes_in_group("entry_point"):
		if entry_point.location == switch_info.entry_point:
			player.global_position = entry_point.global_position + switch_info.entry_offset
			player.safe_spot = player.global_position
			if entry_point.jump:
				player.velocity.y = -180
				player.safe_spot.y -= 16
			break
	# 恢复相机平滑
	game_camera.global_position = player.global_position
	get_tree().paused = false
	game_camera.set_deferred("position_smoothing_enabled", true)
	if (get_tree().get_nodes_in_group("npc").size() > 0
		or get_tree().get_nodes_in_group("switch_moving_path").size() > 0):
		# 有会更新的节点，等待一帧
		await get_tree().process_frame
	UIManager.special_effect.cover_out.call_deferred()
	
func teleport_switch_game_scene(scene_index: int) -> void:
	await UIManager.special_effect.fade_in(1)
	get_tree().paused = true
	SoundManager.stop_bgm()
	await get_tree().create_timer(1).timeout
	SoundManager.play_sfx("CableRun")
	await get_tree().create_timer(3).timeout
	await switch_game_scene(scene_index)
	# 处理玩家位置
	# 暂停相机平滑
	var game_camera: Camera2D = get_game_scene().game_camera
	game_camera.position_smoothing_enabled = false
	var player: Player = get_player()
	var transporter: Node2D = get_tree().get_nodes_in_group("transporter").get(0)
	if transporter != null:
		player.global_position = transporter.global_position
		player.safe_spot = player.global_position
	# 随机朝向
	if randi() % 2 == 0:
		player.face_direction = Constant.Direction.LEFT
	else:
		player.face_direction = Constant.Direction.RIGHT
	# 恢复相机平滑
	game_camera.global_position = player.global_position
	get_tree().paused = false
	game_camera.set_deferred("position_smoothing_enabled", true)
	await UIManager.special_effect.fade_out(1)
	InputManager.disabled = false

func sleepwalk_switch_game_scene(scene_index: int) -> void:
	await UIManager.special_effect.fade_in(1)
	get_tree().paused = true
	SoundManager.stop_bgm()
	for _i in range(10):
		SoundManager.play_sfx("PlayerStep")
		await get_tree().create_timer(0.2).timeout
	await get_tree().create_timer(1).timeout
	await switch_game_scene(scene_index)
	# 处理玩家位置
	# 暂停相机平滑
	var game_camera: Camera2D = get_game_scene().game_camera
	game_camera.position_smoothing_enabled = false
	var player: Player = get_player()
	player.state_machine.disabled = true
	if scene_index != 180:
		var transporter: Node2D = get_tree().get_nodes_in_group("transporter").get(0)
		if transporter != null:
			player.global_position = transporter.global_position
	else:
		player.global_position = Vector2(192, 96)
	# 随机朝向
	if randi() % 2 == 0:
		player.face_direction = Constant.Direction.LEFT
		player.global_position.x -= 16
	else:
		player.face_direction = Constant.Direction.RIGHT
		player.global_position.x += 16
	player.safe_spot = player.global_position
	# 恢复相机平滑
	game_camera.global_position = player.global_position
	get_tree().paused = false
	game_camera.set_deferred("position_smoothing_enabled", true)
	# 播放醒来动画
	player.animation_play("sleeping")
	await get_tree().process_frame
	await UIManager.special_effect.fade_out(1)
	player.animation_play("awake")
	await player.animation_player.animation_finished
	# 恢复控制
	player.state_machine.disabled = false
	InputManager.disabled = false

func story_change_scene(scene_path: String) -> void:
	UIManager.special_effect.cover_in()
	InputManager.disabled = true
	get_tree().paused = true
	object_pool_request.clear()
	get_tree().change_scene_to_file(scene_path)
	await new_scene_ready
	get_game_scene().game_camera.position_smoothing_enabled = false
	get_tree().paused = false
	get_game_scene().game_camera.set_deferred("position_smoothing_enabled", true)
	


# 切换场景
func switch_game_scene(scene_index: int) -> void:
	object_pool_request.clear()
	get_tree().change_scene_to_packed.call_deferred(scene_loader.get_scene(scene_index))
	await new_scene_ready
	_handle_neighbor_scene()

# 处理邻近场景
func _handle_neighbor_scene() -> void:
	var neighbor_index: Array[int] = [get_game_scene().get_scene_index()]
	for teleporter: Teleporter in get_tree().get_nodes_in_group("teleporter"):
		neighbor_index.append(teleporter.target_scene)
	# 删除非邻近场景
	scene_loader.remove_unused_scene(neighbor_index)
	# 加载新场景
	scene_loader.load_scene_request(neighbor_index)

# 注册对象池
func register_object_pool(obj_name: StringName, count: int) -> void:
	var remaining: int = count
	while remaining > 0:
		var batch: int = min(remaining, 5)
		var req: ObjectPool.Request = ObjectPool.Request.new()
		req.name = obj_name
		if not Constant.object_dict.has(obj_name):
			break
		req.resource = Constant.object_dict.get(obj_name, null)
		req.count = batch
		object_pool_request.append(req)
		remaining -= batch
		
func get_game_scene() -> Scene:
	if get_tree().current_scene is Scene and get_tree().current_scene.is_node_ready():
		return get_tree().current_scene
	return null

func get_player() -> Player:
	if get_game_scene() != null and get_game_scene().player != null:
		return get_game_scene().player
	return null

func get_object(obj_name: StringName) -> Node:
	return get_game_scene().object_pool.get_object(obj_name)

func _on_lapse_timeout() -> void:
	if get_game_scene() != null:
		Status.scene_status.lapse += 1
