extends Action

@export var action_btree: BehaviorTreeNode = null ## 主行为树
@export var stage_percentage_thresholds: Array[int] = [] ## 换阶段百分比阈值

func _ready() -> void:
	super ()
	stage_percentage_thresholds.sort()
	UIManager.status_panel.boss_health_bar_container.update_separator(stage_percentage_thresholds)

func tick(_delta: float) -> BTState:
	var new_stage: int = _get_new_stage()
	if new_stage != character.battle_stage:
		character.battle_stage = new_stage
		# 重置行为树
		action_btree.reset()
	return BTState.RUNNING

func _get_new_stage() -> int:
	# 根据血量百分比改变战斗阶段
	var current_health_percentage: int = int(ceilf(character.status.health / float(character.status.max_health) * 100))
	for i in range(stage_percentage_thresholds.size()):
		if current_health_percentage <= stage_percentage_thresholds[i]:
			return stage_percentage_thresholds.size() - i
	return 0
