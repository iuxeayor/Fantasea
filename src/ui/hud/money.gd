extends Label

const MONEY_ROLL_PER_SECOND: float = 30 ## 金钱滚动速度

var money_count_tween: Tween = null

var real_money_count: int = 0
var display_money_count: int = 0:
	set(v):
		display_money_count = v
		text = str(display_money_count)

func _ready() -> void:
	display_money_count = 0

func update(count: int) -> void:
	real_money_count = count
	if money_count_tween != null and money_count_tween.is_running():
			money_count_tween.kill()
	if get_tree().paused:
		display_money_count = real_money_count
		text = str(display_money_count)
		return
	if display_money_count != real_money_count:
		var time: float = max(abs(real_money_count - display_money_count) / MONEY_ROLL_PER_SECOND, 0.05)
		money_count_tween = create_tween()
		money_count_tween.tween_property(self, "display_money_count", real_money_count, time)
