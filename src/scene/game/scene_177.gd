extends "res://src/scene/game/base/ship_scene.gd"

const LIMIT_Y: int = 32

@onready var can: CharacterBody2D = $Units/Can

func _before_ready() -> void:
	super()
	if player.status.money >= 100:
		can.normal_dialog.get_target("CAN_MONEY").disabled = true
	if explore_status == Constant.ExploreStatus.COMPLETE:
		can.dialog.root_dialog = can.normal_dialog
	

func _on_can_updated(context: String) -> void:
	match context:
		"start":
			game_camera.limit_bottom = LIMIT_Y
			# 延展仅在移动设备上生效
			if Util.is_touchscreen_platform():
				var screen_width: int = ProjectSettings.get_setting("display/window/size/viewport_width")
				var screen_height: int = ProjectSettings.get_setting("display/window/size/viewport_height")
				var base_ratio: float = float(screen_width) / float(screen_height)
				var screen_size: Vector2 = get_viewport().get_visible_rect().size
				var screen_ratio: float = screen_size.x / screen_size.y
				if screen_ratio < base_ratio:
					var expand: int = roundi((screen_size.y - screen_size.x / base_ratio) / 2)
					game_camera.limit_bottom += expand
		"story":
			can.dialog.root_dialog = can.normal_dialog
			_limit_camera()
			explore_status = Constant.ExploreStatus.COMPLETE
		"money":
			Game.get_game_scene().drop_loot(can.global_position + Vector2(0, -8), Constant.Loot.COIN_100, 1)
