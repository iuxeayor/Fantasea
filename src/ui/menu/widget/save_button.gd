extends Button
class_name SaveButton

@export var save_name: StringName = ""

var menu_message: String = tr("SAVE_EMPTY_DESC")

func _ready() -> void:
	read_save_data("language")
	Config.config_changed.connect(read_save_data)
	Status.saved.connect(func(_b: bool) -> void:
		read_save_data("language")
	)

func read_save_data(config_name: StringName) -> void:
	if config_name != "language":
		return
	disabled = false
	var save: ConfigFile = ConfigFile.new()
	# 存档不存在，显示空存档
	if save.load(Game.SAVE_PATH % save_name) != OK:
		text = tr("SAVE_EMPTY")
		menu_message = tr("SAVE_EMPTY_DESC")
		disabled = true
		return
	# 系统信息
	# 使用Util的自定义方法读取存档数据
	var loaded_version: Array[int] = Util.get_value_from_config(save, "system", "version", [0, 0, 0])
	var save_time_unix: int = Util.get_value_from_config(save, "system", "time", 0)
	# 状态信息
	var lapse: int = Util.get_value_from_config(save, "status", "lapse", 0)
	var scene_index: int = Util.get_value_from_config(save, "status", "scene_index", 1)
	var scene_explored: Dictionary[int, Constant.ExploreStatus] = {} as Dictionary[int, Constant.ExploreStatus]
	for i in range(Constant.SCENE_COUNT):
		scene_explored[i] = Constant.ExploreStatus.UNKNOWN
		if save.has_section("scene_explore"):
			scene_explored[i] = Util.get_value_from_config(save,
				"scene_explore",
				str(i),
				Constant.ExploreStatus.UNKNOWN) # 场景探索
	# 玩家信息
	var health_chip_collect: int = Util.get_value_from_config(save, "collection", "health_chip", 0)
	var potion: int = Util.get_value_from_config(save, "collection", "potion", 0)
	var potion_store: int = Util.get_value_from_config(save, "player", "potion", 0)
	var money: int = Util.get_value_from_config(save, "player", "money", 0)
	# 处理文本
	var scene_name: String = tr(Util.scene_index_to_name(scene_index))
	var lapse_display: String = Time.get_time_string_from_unix_time(lapse)
	var save_time_display: String = Util.unix_time_to_string(save_time_unix)
	var explore_percentage: int = Util.get_explore_percentage(scene_explored)
	var max_health: int = Util.get_max_health(health_chip_collect)
	# %s  %d%%\n生命：%d  硬币：%d\n%s
	text = tr("SAVE_SLOT") % [
		tr(scene_name),
		explore_percentage,
		max_health,
		money,
		lapse_display]
	# 版本：%s\n存档点：%s\n进度：%d%%\n生命：%d\n牛奶：%d/%d\n硬币：%d\n游戏时间：%s\n保存时间：%s
	var message: String = tr("SAVE_SLOT_DESC") % [
		"%d.%d.%d" % loaded_version,
		tr(scene_name),
		explore_percentage,
		max_health,
		potion,
		potion_store,
		money,
		lapse_display,
		save_time_display]
	# 游戏通关在存档名前加*
	if Util.get_value_from_config(save, "story", "game_clear", false):
		text = "(*) " + text
	if not _is_close_version(loaded_version):
		text = "%s\n%s" % [text, tr("SAVE_SLOT_OUTDATE")]
		menu_message = "%s\n%s" % [tr("SAVE_OUTDATE_DESC"), message]
	else:
		menu_message = message

func _is_close_version(version: Array[int]) -> bool:
	if version.size() != 3:
		return false
	if version[0] != Game.VERSION[0]: # 主版本只要不相等就算不兼容
		return false
	if abs(version[1] - Game.VERSION[1]) >= 2: # 次要版本相差超过2
		return false
	return true

func _on_pressed() -> void:
	Game.save_name = save_name
