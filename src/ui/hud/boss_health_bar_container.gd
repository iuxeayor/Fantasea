extends PanelContainer

var bar_value_tween: Tween = null

@onready var boss_health_bar: TextureProgressBar = $BossHealthBar
@onready var separator_1: VSeparator = $Separators/Separator1
@onready var separator_2: VSeparator = $Separators/Separator2
@onready var separator_3: VSeparator = $Separators/Separator3
@onready var separator_4: VSeparator = $Separators/Separator4
@onready var separator_5: VSeparator = $Separators/Separator5
@onready var separator_6: VSeparator = $Separators/Separator6
@onready var separator_7: VSeparator = $Separators/Separator7
@onready var separator_8: VSeparator = $Separators/Separator8
@onready var separator_9: VSeparator = $Separators/Separator9


@onready var separators: Dictionary[int, VSeparator] = {
	10: separator_1,
	20: separator_2,
	30: separator_3,
	40: separator_4,
	50: separator_5,
	60: separator_6,
	70: separator_7,
	80: separator_8,
	90: separator_9
}

func _ready() -> void:
	# 初始化分隔符
	for percent: int in separators.keys():
		separators[percent].modulate.a = 0.0

func update_value(value: int, max_value: int) -> void:
	if bar_value_tween != null and bar_value_tween.is_running():
		bar_value_tween.kill()
	# 满血无需延迟
	if value == max_value:
		boss_health_bar.value = max_value
		return
	var real_value: float = snappedf(float(value) / max_value * 100, 0.01)
	bar_value_tween = create_tween()
	bar_value_tween.tween_property(boss_health_bar, "value", real_value, 0.1)

# 根据百分比显示分隔符
func update_separator(data: Array[int]) -> void:
	for percent: int in separators.keys():
		if percent in data:
			separators[percent].modulate.a = 1.0
		else:
			separators[percent].modulate.a = 0.0
