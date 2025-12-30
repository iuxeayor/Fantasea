extends Node

enum Bus {
	MASTER = 0,
	SFX = 1,
	BGM = 2,
}

enum Direction {
	LEFT = -1,
	RIGHT = 1,
}

enum ControlDirection {
	LEFT = -1,
	NONE = 0,
	RIGHT = 1,
}

enum ExploreStatus {
	UNKNOWN = 0,
	EXPLORED = 1,
	COMPLETE = 2,
}

enum SceneEnvironment {
	SWAP = 0,
	FOREST = 1,
	ISLAND = 2,
	SNOWFIELD = 3,
	DESERT = 4,
	CAVE = 5,
	SHIP = 6
}


enum Loot {
	COIN_1 = 0,
	COIN_10 = 1,
	COIN_100 = 2,
	MILK = 3,
}

enum UseableItem {
	NONE = -1,
	WATERMELON_SEED = 0, # 西瓜籽
	JELLY = 1, # 果冻
	BLOCK = 2, # 方块
	CHERRY_BOMB = 3, # 樱桃炸弹
}

# 中心点用于传送
enum EntryPoint {
	NONE = -1,
	LEFT = 0,
	LEFT_TOP = 1,
	TOP = 2,
	RIGHT_TOP = 3,
	RIGHT = 4,
	RIGHT_BOTTOM = 5,
	BOTTOM = 6,
	LEFT_BOTTOM = 7,
	CENTER = 8,
}

# 菜单
enum GameMenu {
	NONE = -1,
	SETTING = 0,
	IN_GAME = 1,
	LOAD_SAVE = 2,
	NEW_GAME = 3
}

# 物理信息
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
const MOVE_SPEED: float = 120
const ACCELERATION_MULTIPLIER: float = 5
const MAX_FALL_VELOCITY: float = 360
const MAX_JUMP_VELOCITY: float = -300
const MIN_JUMP_VELOCITY: float = -100
const JELLY_BOUNCE_VELOCITY: float = -340
const WALL_SLIDE_VELOCITY: float = 30
const WALL_JUMP_HORIZONTAL_SPEED: float = 120
const WALL_JUMP_VERTICAL_VELOCITY: float = -210
const DOUBLE_JUMP_VELOCITY: float = -240
const MAX_DASH_SPEED: float = 300
const MIN_DASH_SPEED: float = 160
const KNOCKBACK_HORIZONTAL_SPEED: float = 60
const KNOCKBACK_VERTICAL_VELOCITY: float = -100
const DASH_SHIELD_KNOCKBACK_HORIZONTAL_SPEED: float = 20
const DASH_SHIELD_KNOCKBACK_VERTICAL_VELOCITY: float = -40
const HIT_KNOCKBACK_HORIZONTAL_SPEED: float = 40
const HIT_KNOCKBACK_VERTICAL_VELOCITY: float = -60
const EDGE_SLIDE_VELOCITY: float = 60

# 玩家基础数据
const BASE_HP: int = 5 # 基础生命值
const HEALTH_CHIP_DIVISION: int = 3 # 生命碎片对完整生命的除数
const HEAL_TIME: float = 1.2 # 默认治疗时间
const HEAL_TIME_FAST: float = 0.8 # 快速治疗时间
const HURT_TIME: float = 0.8 # 受伤无敌时间
const EXTEND_HURT_TIME: float = 1.2 # 受伤无敌时间延长
const SHOOT_CD_TIME: float = 0.6 # 射击冷却时间
const DASH_SHIELD_HURT_TIME: float = 0.4 # 冲刺护盾受伤无敌时间
const EXTEND_DASH_SHIELD_HURT_TIME: float = 0.6 # 冲刺护盾受伤无敌时间延长
const FAST_SHOOT_CD_TIME: float = 0.5 # 快速射击冷却时间
var attack: Array[int] = [0, 4, 6, 8, 10, 12]
var shoot_attack: Array[int] = [1, 1, 1, 2, 3, 4]
const AUTO_HEAL_TIME: float = 6 # 自动治疗的时间间隔
const FAST_AUTO_HEAL_TIME: float = 4 # 快速自动治疗的时间间隔
const ATTACK_CD_TIME: float = 0.2
const FAST_ATTACK_CD_TIME: float = 0.15

# 场景数量，从0计数，所以实际数量要加1
const SCENE_COUNT: int = 246

# UI使用，字符出现速度
const CHARACTER_PER_SECOND_FAST: int = 150
const CHARACTER_PER_SECOND_SLOW: int = 50

# 对象Dict，用于自动管理对象
# 理论上应该手动填入，但是管理起来太麻烦，所以使用这个Dict来自动管理
var object_dict: Dictionary[StringName, PackedScene] = {}
func register_object(object_name: StringName, resource: PackedScene) -> void:
	object_dict[object_name] = resource

const ENEMY_DATA: Dictionary[StringName, Dictionary] = {
	# 森林
	"apple": {
		"max_health": 10,
		"min_drop_coin": 1,
		"max_drop_coin": 2,
	},
	"banana": {
		"max_health": 8,
		"min_drop_coin": 2,
		"max_drop_coin": 4,
	},
	"orange": {
		"max_health": 8,
		"min_drop_coin": 2,
		"max_drop_coin": 4,
	},
	"lemon": {
		"max_health": 18,
		"min_drop_coin": 6,
		"max_drop_coin": 8,
	},
	"golden_needle_mushroom": {
		"max_health": 30,
		"min_drop_coin": 20,
		"max_drop_coin": 40,
	},
	"black_mushroom": {
		"max_health": 4,
		"min_drop_coin": 2,
		"max_drop_coin": 6,
	},
	# 岛屿
	"sausage": {
		"max_health": 18,
		"min_drop_coin": 3,
		"max_drop_coin": 5,
	},
	"popcorn": {
		"max_health": 14,
		"min_drop_coin": 4,
		"max_drop_coin": 6,
	},
	"bubble_tea": {
		"max_health": 12,
		"min_drop_coin": 4,
		"max_drop_coin": 6,
	},
	"chocolate": {
		"max_health": 16,
		"min_drop_coin": 0,
		"max_drop_coin": 0,
	},
	"chocolate_chuck": {
		"max_health": 4,
		"min_drop_coin": 0,
		"max_drop_coin": 2,
	},
	# 雪原
	"shaved_ice": {
		"max_health": 16,
		"min_drop_coin": 4,
		"max_drop_coin": 8,
	},
	"ice_cream": {
		"max_health": 18,
		"min_drop_coin": 4,
		"max_drop_coin": 8,
	},
	"ice_pop": {
		"max_health": 10,
		"min_drop_coin": 6,
		"max_drop_coin": 10,
	},
	"sushi": {
		"max_health": 24,
		"min_drop_coin": 8,
		"max_drop_coin": 16,
	},
	"yogurt": {
		"max_health": 18,
		"min_drop_coin": 8,
		"max_drop_coin": 12,
	},
	"salad": {
		"max_health": 36,
		"min_drop_coin": 10,
		"max_drop_coin": 20,
	},
	# 荒漠
	"skewer": {
		"max_health": 20,
		"min_drop_coin": 5,
		"max_drop_coin": 9,
	},
	"walnut": {
		"max_health": 60,
		"min_drop_coin": 12,
		"max_drop_coin": 20,
	},
	"chili": {
		"max_health": 14,
		"min_drop_coin": 6,
		"max_drop_coin": 10,
	},
	"raisin": {
		"max_health": 50,
		"min_drop_coin": 15,
		"max_drop_coin": 25,
	},
	"small_raisin": {
		"max_health": 4,
		"min_drop_coin": 0,
		"max_drop_coin": 0,
	},
	"naan": {
		"max_health": 120,
		"min_drop_coin": 20,
		"max_drop_coin": 40,
	},
	# 洞穴
	"rum": {
		"max_health": 24,
		"min_drop_coin": 8,
		"max_drop_coin": 12,
	},
	"paocai": {
		"max_health": 60,
		"min_drop_coin": 15,
		"max_drop_coin": 25,
	},
	"pickle": {
		"max_health": 30,
		"min_drop_coin": 10,
		"max_drop_coin": 20,
	},
}