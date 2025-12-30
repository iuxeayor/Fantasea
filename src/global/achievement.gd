extends Node

enum ID {
	# 剧情类
	STORY_START, # 通过新手教程
	STORY_SHIP, # 登上莫尔号
	STORY_END, # 通关
	# 收集类
	COLLECT_100_COINS, # 收集100金币
	COLLECT_MAX_HEALTH, # 生命值提升至最大
	COLLECT_MAX_POTION, # 药水数量提升至最大
	COLLECT_MAX_ATTACK, # 攻击力提升至最大
	COLLECT_100_MILK, # 收集100瓶牛奶
	COLLECT_ALL_ITEM, # 收集所有物品
	COLLECT_ANYTHING, # 全部收集
	# 战斗类
	DEFEAT_WATERMELON, # 击败西瓜
	DEFEAT_PEANUT_BUTTER, # 击败花生酱
	DEFEAT_ICE, # 击败冰块
	DEFEAT_BUTTER, # 击败黄油
	DEFEAT_BIG_MUSHROOM, # 击败大蘑菇
	DEFEAT_HAM, # 击败火腿
	DEFEAT_CALIFORNIA_ROLL, # 击败加州卷
	DEFEAT_BAIJIU, # 击败白酒
	DEFEAT_COMBO, # 击败套餐
	DEFEAT_WHOLE_WHEAT_BREAD, # 击败全麦面包
	# 探索类
	EXPLORE_FOREST, # 探索萌芽森林
	EXPLORE_ISLAND, # 探索十字岛
	EXPLORE_SNOWFIELD, # 探索霜冻山脉
	EXPLORE_DESERT, # 探索回响荒漠
	EXPLORE_CAVE, # 探索幽暗石窟
	EXPLORE_SHIP, # 探索莫尔号
	EXPLORE_ALL_BANG_PARK, # 探索所有棒乐园区域
	EXPLORE_100_PERCENT, # 完全探索100%地图
}

# 触发成就
func set_achievement(achievement_id: ID) -> void:
	_set_platform_achievement(achievement_id)

func _set_platform_achievement(achievement_id: ID) -> void:
	match achievement_id:
		ID.STORY_START:
			PlatformManager.set_steam_achievement("ACH_STORY_START")
		ID.STORY_SHIP:
			PlatformManager.set_steam_achievement("ACH_STORY_SHIP")
		ID.STORY_END:
			PlatformManager.set_steam_achievement("ACH_STORY_END")
		ID.COLLECT_100_COINS:
			PlatformManager.set_steam_achievement("ACH_COLLECT_100_COINS")
		ID.COLLECT_MAX_HEALTH:			
			PlatformManager.set_steam_achievement("ACH_COLLECT_MAX_HEALTH")
		ID.COLLECT_MAX_POTION:
			PlatformManager.set_steam_achievement("ACH_COLLECT_MAX_POTION")
		ID.COLLECT_MAX_ATTACK:
			PlatformManager.set_steam_achievement("ACH_COLLECT_MAX_ATTACK")
		ID.COLLECT_100_MILK:
			PlatformManager.set_steam_achievement("ACH_COLLECT_100_MILK")
		ID.COLLECT_ALL_ITEM:
			PlatformManager.set_steam_achievement("ACH_COLLECT_ALL_ITEM")
		ID.COLLECT_ANYTHING:
			PlatformManager.set_steam_achievement("ACH_COLLECT_ANYTHING")
		ID.DEFEAT_WATERMELON:
			PlatformManager.set_steam_achievement("ACH_DEFEAT_WATERMELON")
		ID.DEFEAT_PEANUT_BUTTER:
			PlatformManager.set_steam_achievement("ACH_DEFEAT_PEANUT_BUTTER")
		ID.DEFEAT_ICE:
			PlatformManager.set_steam_achievement("ACH_DEFEAT_ICE")
		ID.DEFEAT_BUTTER:
			PlatformManager.set_steam_achievement("ACH_DEFEAT_BUTTER")
		ID.DEFEAT_BIG_MUSHROOM:
			PlatformManager.set_steam_achievement("ACH_DEFEAT_BIG_MUSHROOM")
		ID.DEFEAT_HAM:
			PlatformManager.set_steam_achievement("ACH_DEFEAT_HAM")
		ID.DEFEAT_CALIFORNIA_ROLL:
			PlatformManager.set_steam_achievement("ACH_DEFEAT_CALIFORNIA_ROLL")
		ID.DEFEAT_BAIJIU:
			PlatformManager.set_steam_achievement("ACH_DEFEAT_BAIJIU")
		ID.DEFEAT_COMBO:
			PlatformManager.set_steam_achievement("ACH_DEFEAT_COMBO")
		ID.DEFEAT_WHOLE_WHEAT_BREAD:
			PlatformManager.set_steam_achievement("ACH_DEFEAT_WHOLE_WHEAT_BREAD")
		ID.EXPLORE_FOREST:
			PlatformManager.set_steam_achievement("ACH_EXPLORE_FOREST")
		ID.EXPLORE_ISLAND:
			PlatformManager.set_steam_achievement("ACH_EXPLORE_ISLAND")
		ID.EXPLORE_SNOWFIELD:
			PlatformManager.set_steam_achievement("ACH_EXPLORE_SNOWFIELD")
		ID.EXPLORE_DESERT:
			PlatformManager.set_steam_achievement("ACH_EXPLORE_DESERT")
		ID.EXPLORE_CAVE:
			PlatformManager.set_steam_achievement("ACH_EXPLORE_CAVE")
		ID.EXPLORE_SHIP:
			PlatformManager.set_steam_achievement("ACH_EXPLORE_SHIP")
		ID.EXPLORE_ALL_BANG_PARK:
			PlatformManager.set_steam_achievement("ACH_EXPLORE_ALL_BANG_PARK")
		ID.EXPLORE_100_PERCENT:
			PlatformManager.set_steam_achievement("ACH_EXPLORE_100_PERCENT")
