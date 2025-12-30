extends HBoxContainer

var direction: Vector2 = Vector2.ZERO

var opening: bool = false:
	set(v):
		opening = v
		mini_map.opening = opening
		if opening:
			show()
			set_process(true)
			if mini_map != null and Game.get_game_scene() != null:
				var scene: Scene = Game.get_game_scene()
				mini_map.center_to(scene.get_scene_index())
				mini_map.move_player_icon_to(scene.get_scene_index(), scene.get_player_position_ratio())
		else:
			hide()
			set_process(false)
			
@onready var mini_map: Node2D = $SubViewportContainer/SubViewport/MiniMap
@onready var control_container: VBoxContainer = $ControlContainer

func _ready() -> void:
	control_container.visible = Util.is_touchscreen_platform()

func _process(delta: float) -> void:
	if not opening:
		return
	if direction != Vector2.ZERO:
		mini_map.camera.global_position += direction.normalized() * mini_map.camera_speed * delta
