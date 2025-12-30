extends TileMapLayer

var change_time: float = 0.2

func _ready() -> void:
	# 编辑器中半透明以方便修改，正式使用时不透明
	modulate.a = 1

func fade_out() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate:a", 0, change_time)

func fade_in() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate:a", 1, change_time)
