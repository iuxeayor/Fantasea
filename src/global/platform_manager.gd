extends Node

const STEAM_APP_ID: int = 0  # 应用ID
var steam: Object = null
var is_steam_ready: bool = false # Steam初始化状态
var is_steam_online: bool = false # Steam在线状态
var is_steam_owned: bool = false # Steam拥有状态
var steam_id: int = 0 # Steam用户ID

@onready var steam_push_timer: Timer = $SteamPushTimer

func _ready() -> void:
	set_process(false)
	_ready_steam()
	set_process(is_steam_ready)


func _ready_steam() -> void:
	if Engine.has_singleton("Steam") and STEAM_APP_ID > 0:
		steam = Engine.get_singleton("Steam")
		var init_response: Dictionary = steam.steamInitEx(STEAM_APP_ID, true)
		if init_response.get("status", -1) != 0:
			return
		is_steam_online = steam.loggedOn()
		is_steam_owned = steam.isSubscribed()
		steam_id = steam.getSteamID()
		is_steam_ready = is_steam_online and is_steam_owned
	if is_steam_ready:
		steam_push_timer.start()
		print("Steam check successfully")
	else:
		print("Steam check failed")

func _process(_delta: float) -> void:
	if is_steam_ready:
		steam.run_callbacks()

func set_steam_achievement(achievement_id: String) -> void:
	if is_steam_ready and achievement_id != "":
		var result: bool = steam.setAchievement(achievement_id)
		if result:
			steam_push_timer.start()

func _on_steam_push_timer_timeout() -> void:
	if is_steam_ready:
		steam.storeStats()
