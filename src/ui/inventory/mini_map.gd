extends Node2D

const ROOM_NODE_PATH: String = "Room%d"
const CAMERA_SPEED: float = 120

@onready var camera: Camera2D = $Camera
@onready var rooms: Node2D = $Rooms
@onready var player_icon: TextureRect = $PlayerIcon

var opening: bool = false:
	set(v):
		opening = v
		if opening:
			set_process(true)
		else:
			set_process(false)

func _ready() -> void:
	center_to(0)

func _process(_delta: float) -> void:
	if not opening:
		return
	player_icon.self_modulate = Color(1, 1, 1, sin(float(Time.get_ticks_msec()) / 200))

func _physics_process(delta: float) -> void:
	if not opening:
		return
	camera.global_position += Vector2(
		Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up", "ui_down")
	) * CAMERA_SPEED * delta

func _unhandled_input(event: InputEvent) -> void:
	if opening:
		if event.is_action_pressed("ui_accept") and Game.get_game_scene() != null:
			center_to(Game.get_game_scene().get_scene_index())
			

func center_to(index: int) -> void:
	var room: MapRoom = rooms.get_child(index)
	if room != null:
		camera.global_position = room.center.global_position

func move_player_icon_to(index: int, ratio: Vector2) -> void:
	var room: MapRoom = rooms.get_child(index)
	if room != null:
		player_icon.global_position = room.get_ratio_position(ratio) - Vector2(7, 7)

func update(explore_data: Dictionary[int, Constant.ExploreStatus]) -> void:
	for i: int in range(rooms.get_child_count()):
		var room: MapRoom = rooms.get_child(i)
		if explore_data.get(i, Constant.ExploreStatus.UNKNOWN) == Constant.ExploreStatus.UNKNOWN:
			room.grid_visible = false
		else:
			room.grid_visible = true
			room.is_complete = explore_data[i] == Constant.ExploreStatus.COMPLETE
