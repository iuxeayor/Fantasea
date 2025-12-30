extends Node

signal saving
signal saved(success: bool)
# 玩家信息
class PlayerStatus:
	var health: int = Constant.BASE_HP # 当前生命值
	var money: int = 0 # 当前金钱
	var potion: int = 0 # 当前药水数量
	var potion_store: int = 0 # 药水库存
	# 有数量的收集品 
	var number_collection: Dictionary[String, int] = {
		"health_chip": 0, # 生命碎片
		"potion": 0, # 生命药水
		"weapon_level": 0, # 武器等级
	}
	# 仅有状态的收集品
	var collection: Dictionary[String, bool] = {
		"watermelon_seed": false, # 西瓜籽（远程攻击）
		"jelly": false, # 果冻（跳高）
		"club_soda": false, # 苏打水（冲刺）
		"honey": false, # 蜂蜜（爬墙）
		"gold_steak": false, # 金箔牛排（发光）
		"jelly_pouch": false, # 吸吸果冻（二段跳）
		"bang_card": false, # 棒乐园卡（门禁）
		"chicken_sandwich": false, # 板烧鸡腿堡（收集）
		"want_more_milk": false, # 旺财牛奶（增加金币收集）
		"magnet": false, # 磁铁（吸引金币）
		"nutmeg": false, # 肉豆蔻（梦游到传送点）
		"mushroom_powder": false, # 蘑菇粉（受伤自爆）
		"sweet_jiuniang": false, # 甜酒酿（空中治疗）
		"stinky_tofu": false, # 臭豆腐（延长受伤无敌时间）
		"straw_glasses": false, # 吸管眼镜（自动回血）
		"fresh_milk": false, # 鲜奶（加速回血）
		"frozen_apple": false, # 冻苹果（冲刺时无敌）
		"lemon_slice": false, # 柠檬片（强化远程攻击）
		"hot_sauce": false, # 辣酱（强化近战攻击）
		"silk_tofu": false, # 嫩豆腐（生命全满或只剩一滴时伤害增加）
	}

	# 保存到存档
	func save_to(save: ConfigFile) -> ConfigFile:
		# 玩家信息
		save.set_value("player", "money", money)
		save.set_value("player", "potion", potion_store + potion)
		# 收集信息
		for key: String in number_collection:
			save.set_value("collection", key, number_collection[key])
		for key: String in collection:
			save.set_value("collection", key, collection[key])
		return save
	
	# 从存档加载
	func load_from(save: ConfigFile) -> ConfigFile:
		# 使用自定义Util方法获取health，同时判断可能的错误
		money = Util.get_value_from_config(save, "player", "money", 0)
		potion_store = Util.get_value_from_config(save, "player", "potion", 0)
		for key: String in collection.keys():
			collection[key] = Util.get_value_from_config(save, "collection", key, false)
		for key: String in number_collection.keys():
			number_collection[key] = Util.get_value_from_config(save, "collection", key, 0)
		health = Util.get_max_health(number_collection.get("health_chip", 0))
		return save
	

class SceneStatus:
	var lapse: int = 0 # 游戏时间
	var scene_explore: Dictionary[int, Constant.ExploreStatus] = new_scene_explore() # 探索列表
	var scene_index: int = 1 # 当前场景索引
	# 存储仅用于判断主题，不实际使用
	var scene_environment: Constant.SceneEnvironment = Constant.SceneEnvironment.SWAP # 当前场景环境
	# 剧情
	var story: Dictionary[String, bool] = {
		# 主线
		"main_start": false, # 开始
		"main_sleep": false, # 离家
		"main_break": false, # 破坏
		"butter_break": false, # 黄油破坏
		"game_clear": false, # 通关
	}

	# 新探索列表
	func new_scene_explore() -> Dictionary[int, Constant.ExploreStatus]:
		var result: Dictionary[int, Constant.ExploreStatus] = {}
		for i in range(Constant.SCENE_COUNT):
			result[i] = Constant.ExploreStatus.UNKNOWN
		return result

	func save_to(save: ConfigFile) -> ConfigFile:
		save.set_value("status", "lapse", lapse) # 游戏时间
		save.set_value("status", "scene_index", scene_index) # 场景索引
		save.set_value("status", "scene_environment", scene_environment) # 场景环境
		for i in range(Constant.SCENE_COUNT):
			if scene_explore.has(i):
				save.set_value("scene_explore",
					str(i),
					scene_explore.get(i, Constant.ExploreStatus.UNKNOWN)) # 场景探索
		if Util.get_explore_percentage(scene_explore) >= 100:
			Achievement.set_achievement(Achievement.ID.EXPLORE_100_PERCENT)
		# 剧情信息
		for key: String in story.keys():
			save.set_value("story", key, story[key])
		return save

	func load_from(save: ConfigFile) -> ConfigFile:
		lapse = Util.get_value_from_config(save, "status", "lapse", 0) # 游戏时间
		scene_index = Util.get_value_from_config(save, "status", "scene_index", 1) # 场景索引
		for i in range(Constant.SCENE_COUNT):
			if save.has_section("scene_explore"):
				scene_explore[i] = Util.get_value_from_config(save,
					"scene_explore",
					str(i),
					Constant.ExploreStatus.UNKNOWN) # 场景探索
		# 剧情
		for key: String in story.keys():
			story[key] = Util.get_value_from_config(save, "story", key, false)
		return save

var scene_status: SceneStatus = SceneStatus.new() # 场景信息
var player_status: PlayerStatus = PlayerStatus.new() # 玩家信息

# 切换场景信息
class SwitchSceneInfo:
	var entry_point: Constant.EntryPoint = Constant.EntryPoint.NONE # 入口点
	var entry_offset: Vector2 = Vector2.ZERO # 入口偏移
	var direction: Constant.Direction = Constant.Direction.RIGHT # 方向
	var velocity: Vector2 = Vector2.ZERO # 速度

# 不保存数据
var scene_enemy_data: Dictionary = {} # 敌怪数据

func save_to_file(save_name: StringName) -> void:
	saving.emit()
	var save: ConfigFile = ConfigFile.new()
	save.set_value("system", "version", Game.VERSION) # 版本
	save.set_value("system", "time", int(Time.get_unix_time_from_system())) # 存档时间
	save = scene_status.save_to(save) # 场景信息
	save = player_status.save_to(save) # 玩家信息
	var path: String = Game.SAVE_PATH % save_name
	var success: bool = save.save(path) == OK
	await get_tree().create_timer(0.1).timeout
	if success:
		saved.emit(true)
	else:
		saved.emit(false)

func load_from_file(save_name: StringName) -> void:
	var save: ConfigFile = ConfigFile.new()
	if save.load(Game.SAVE_PATH % save_name) != OK:
		return
	scene_status = SceneStatus.new()
	scene_status.load_from(save)
	player_status = PlayerStatus.new()
	player_status.load_from(save)

# 重置信息
func reset_status() -> void:
	scene_status = SceneStatus.new()
	player_status = PlayerStatus.new()
	scene_enemy_data = {}

func has_collection(coll_name: String) -> bool:
	return player_status.collection.get(coll_name, false)

func handle_achievement() -> void:
	# 18 生命碎片，11 生命药水
	var max_health: bool = player_status.number_collection.get("health_chip", 0) >= 18
	var max_potion: bool = player_status.number_collection.get("potion", 0) >= 11
	var max_attack: bool = player_status.number_collection.get("weapon_level", 0) >= 5
	var milk_store_100: bool = player_status.potion_store >= 100
	var all_item: bool = true
	for key: String in player_status.collection.keys():
		if not player_status.collection.get(key, false):
			all_item = false
			break
	if max_health:
		Achievement.set_achievement(Achievement.ID.COLLECT_MAX_HEALTH)
	if max_potion:
		Achievement.set_achievement(Achievement.ID.COLLECT_MAX_POTION)
	if max_attack:
		Achievement.set_achievement(Achievement.ID.COLLECT_MAX_ATTACK)
	if milk_store_100:
		Achievement.set_achievement(Achievement.ID.COLLECT_100_MILK)
	if all_item:
		Achievement.set_achievement(Achievement.ID.COLLECT_ALL_ITEM)
	if max_health and max_potion and max_attack and all_item:
		Achievement.set_achievement(Achievement.ID.COLLECT_ANYTHING)
	# 棒乐园相关
	if (has_collection("bang_card")
		and has_collection("magnet")
		and has_collection("honey")
		and has_collection("frozen_apple")
		and has_collection("silk_tofu")):
		Achievement.set_achievement(Achievement.ID.EXPLORE_ALL_BANG_PARK)
