extends Label

var low: Array = [0, 0, 0, 0, 0]

@onready var timer: Timer = $Timer
@onready var long_timer: Timer = $LongTimer

# 显示最近低帧/当前帧
# 最近低帧使用一个滑动窗口来计算，获取5个最近的低帧率

func _ready() -> void:
	_handle_display("show_fps")
	Config.config_changed.connect(_handle_display)

func _process(_delta: float) -> void:
	if not Config.show_fps:
		set_process(false)
		return
	var current_frame: int = int(Engine.get_frames_per_second())
	if current_frame < low.back():
		low[low.size() - 1] = current_frame

func _handle_display(config_name: StringName) -> void:
	if config_name != "show_fps":
		return
	set_process(true)
	for i: int in range(low.size()):
		if low[i] == 0:
			low[i] = int(Engine.get_frames_per_second())
	_handle_text()
	if Config.show_fps:
		timer.start()
		long_timer.start()
		show()
	else:
		timer.stop()
		long_timer.stop()
		hide()
	
func _handle_text() -> void:
	text = "%d/%d" % [low.min(), int(Engine.get_frames_per_second())]

func _on_timer_timeout() -> void:
	_handle_text()


func _on_long_timer_timeout() -> void:
	low.remove_at(0)
	low.append(int(Engine.get_frames_per_second()))
