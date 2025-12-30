extends Node


# 抛物线计算，y固定时，到达x的速度
func calculate_x_velocity_parabola(start: Vector2, target: Vector2, velocity_y: float, gravity: float, max_x_distance: float = 480) -> float:
	var x_distance: float = target.x - start.x
	# 限制最大距离
	if abs(x_distance) > max_x_distance:
		x_distance = max_x_distance * sign(x_distance)
	var y_distance: float = target.y - start.y
	var discriminant: float = velocity_y * velocity_y + 2 * gravity * y_distance
	if discriminant < 0:
		return 0 # 无法到达目标
	var time1: float = (-velocity_y + sqrt(discriminant)) / gravity
	var time2: float = (-velocity_y - sqrt(discriminant)) / gravity
	if time1 <= 0 and time2 <= 0:
		return 0 # 时间不能为负或零
	var velocity_x: float = x_distance / max(time1, time2)
	return velocity_x

# 抛物线计算，x固定时，y的速度
func calculate_y_velocity_parabola(start: Vector2, target: Vector2, velocity_x: float, gravity: float) -> float:
	var x_distance: float = target.x - start.x
	var y_distance: float = target.y - start.y
	# 计算所需的时间
	var time: float = x_distance / velocity_x
	# 确保时间是正数
	if time <= 0:
		return 0
	# 使用运动方程计算初始纵向速度
	var velocity_y: float = (y_distance - 0.5 * gravity * time * time) / time
	return velocity_y

# 将输入值从区间 origin_min-origin_max 映射到区间 target_min-target_max
func map_range(input: float, origin_min: float, origin_max: float, target_min: float, target_max: float) -> float:
	if origin_min == origin_max:
		return (target_min + target_max) / 2
	if input <= origin_min:
		return target_min
	elif input >= origin_max:
		return target_max
	else:
		# 线性映射公式
		return (target_min 
			+ (input - origin_min) 
			* (target_max - target_min) 
			/ (origin_max - origin_min))

func get_char_per_second() -> int:
	match TranslationServer.get_locale():
		"zh_CN", "zh_HK":
			return Constant.CHARACTER_PER_SECOND_SLOW
		_:
			return Constant.CHARACTER_PER_SECOND_FAST

func get_max_health(health_chip_count: int) -> int:
	return Constant.BASE_HP + floori(health_chip_count / float(Constant.HEALTH_CHIP_DIVISION))

func get_attack_power(weapon_level: int) -> int:
	if weapon_level < 0 or weapon_level >= Constant.attack.size():
		return 0
	return Constant.attack[weapon_level]

func get_shoot_power(weapon_level: int) -> int:
	if weapon_level < 0 or weapon_level >= Constant.shoot_attack.size():
		return 1
	return Constant.shoot_attack[weapon_level]

func get_explore_percentage(scene_explore: Dictionary[int, Constant.ExploreStatus]) -> int:
	if scene_explore.is_empty():
		return 0
	var explored_count: int = 0
	for index: int in scene_explore.keys():
		if scene_explore.get(index, Constant.ExploreStatus.UNKNOWN) == Constant.ExploreStatus.COMPLETE:
			explored_count += 1
	return floori(explored_count / float(scene_explore.size()) * 100)

func scene_index_to_name(index: int) -> String:
	match index:
		1:
			return "SCENE_FOREST_START"
		8:
			return "SCENE_FOREST_BASEMENT"
		9:
			return "SCENE_FOREST_VILLAGE"
		16:
			return "SCENE_FOREST_MIDDLE"
		40:
			return "SCENE_ISLAND_WEST"
		52:
			return "SCENE_ISLAND_EAST"
		70:
			return "SCENE_SNOWFIELD_VILLAGE"
		83:
			return "SCENE_SNOWFIELD_HIGHLAND"
		90:
			return "SCENE_DESERT_CAMP"
		102:
			return "SCENE_DESERT_PLAYGROUND_START"
		112:
			return "SCENE_DESERT_PLAYGROUND_END"
		125:
			return "SCENE_SNOWFIELD_MOUNTAINSIDE"
		165:
			return "SCENE_FOREST_CAVE"
		169:
			return "SCENE_SNOWFIELD_WIND"
		173:
			return "SCENE_SHIP_CHECKPOINT"
		176:
			return "SCENE_SHIP_DECK"
		186:
			return "SCENE_DESERT_UNDERGROUND"
		206:
			return "SCENE_CAVE_CELLAR"
		238:
			return "SCENE_SHIP_HOLD"
		_:
			return "SCENE_UNKNOWN"

func unix_time_to_string(unix_time: int) -> String:
	var time: Dictionary = Time.get_datetime_dict_from_unix_time(unix_time)
	return "%d/%02d/%02d-%02d:%02d:%02d" % [
			time.get("year", 1970),
			time.get("month", 1),
			time.get("day", 1),
			time.get("hour", 0),
			time.get("minute", 0),
			time.get("second", 0)
		]

func get_value_from_config(config: ConfigFile, section: String, key: String, default_value: Variant) -> Variant:
	var value: Variant = config.get_value(section, key, default_value)
	if (value != null
		and typeof(value) == typeof(default_value)):
		return value
	return default_value

func get_value_from_dict(config: Dictionary, key: String, default_value: Variant) -> Variant:
	if config.has(key):
		var value: Variant = config.get(key)
		if (value != null
			and typeof(value) == typeof(default_value)):
			return value
	return default_value

# 检查是否有存档文件
func is_has_save_file() -> bool:
	var dir: DirAccess = DirAccess.open(Game.SAVE_PATH_DIR)
	if dir != null:
		dir.list_dir_begin()
		var file_name: String = dir.get_next()
		while file_name != "":
			if (not dir.current_is_dir()
				and file_name.begins_with("save")
				and file_name.ends_with(".sav")):
				var idx: String = file_name.get_slice("save", 1).get_slice(".", 0)
				if idx.is_valid_int():
					return true
			file_name = dir.get_next()
	return false

func is_touchscreen_platform() -> bool:
	for param: String in OS.get_cmdline_args():
		if param == "--touchscreen":
			return true
	var enable_features: Array[String] = [
		"android",
		"ios",
		"mobile",
		"web_android",
		"web_ios",
	]
	for feature: String in enable_features:
		if OS.has_feature(feature):
			return true
	return false

func is_mobile_platform() -> bool:
	for param: String in OS.get_cmdline_args():
		if param == "--mobile":
			return true
	var mobile_features: Array[String] = [
		"android",
		"ios",
		"mobile",
		"web_android",
		"web_ios",
	]
	for feature: String in mobile_features:
		if OS.has_feature(feature):
			return true
	return false

func is_web_platform() -> bool:
	var web_features: Array[String] = [
		"web",
		"web_android",
		"web_ios",
		"web_linuxbsd",
		"web_macos",
		"web_windows",
	]
	for feature: String in web_features:
		if OS.has_feature(feature):
			return true
	return false