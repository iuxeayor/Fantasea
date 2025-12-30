extends "res://src/scene/game/base/ship_scene.gd"

@onready var ship_guard: CharacterBody2D = $Units/ShipGuard
@onready var electrical_cable: CharacterBody2D = $Units/ElectricalCable
@onready var player_light: PointLight2D = $Player/PlayerLight
@onready var dark_light: DirectionalLight2D = $Lights/DarkLight

func _before_ready() -> void:
	super()
	if explore_status == Constant.ExploreStatus.COMPLETE:
		dark_light.queue_free()
		player_light.queue_free()
		electrical_cable.collision_shape_2d.set_deferred("disabled", true)
		electrical_cable.animation_play("connect")
		if Status.scene_status.scene_explore[177] != Constant.ExploreStatus.COMPLETE:
			ship_guard.dialog.root_dialog = ship_guard.normal_dialog
	else:
		ship_guard.dialog.root_dialog = ship_guard.powerless_dialog

func _on_electrical_cable_completed() -> void:
	dark_light.queue_free()
	player_light.queue_free()
	electrical_cable.dialog.disabled = true
	electrical_cable.collision_shape_2d.set_deferred("disabled", true)
	if Status.scene_status.scene_explore[177] == Constant.ExploreStatus.COMPLETE:
		ship_guard.dialog.root_dialog = ship_guard.pass_dialog
	else:
		ship_guard.dialog.root_dialog = ship_guard.normal_dialog
	SoundManager.play_sfx("PowerClose")
	InputManager.disabled = false
	explore_status = Constant.ExploreStatus.COMPLETE
